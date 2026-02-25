/*
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 A class to fetch and cache data from the remote server.
 */

import Foundation

actor QuakeClient {
    private let quakeCache: NSCache<NSString, CacheEntryObject> = NSCache()

    private var decoder: JSONDecoder = {
        let aDecoder = JSONDecoder()
        aDecoder.dateDecodingStrategy = .millisecondsSince1970
        return aDecoder
    }()

    /// Geological data provided by the U.S. Geological Survey (USGS). See ACKNOWLEDGMENTS.txt for additional details.
    private let feedURL = URL(
        string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson"
    )!

    private let downloader: any HTTPDataDownloader

    // 읽기 전용 연산 프로퍼티. 프로퍼티에 접근할 때 비동기(async)로 동작하며 에러를 던질 수(throws) 있습니다.
    var quakes: [Quake] {
        get async throws {
            // 1. 설정된 URL(feedURL)에서 비동기(await)로 통신하여 데이터를 가져옵니다. 실패 시 에러가 던져집니다(try).
            let data = try await downloader.httpData(from: feedURL)

            // 2. 가져온 JSON 데이터를 JSONDecoder(decoder)를 이용해 GeoJSON 형식(커스텀 타입)으로 디코딩(변환)합니다.
            let allQuakes = try decoder.decode(GeoJSON.self, from: data)

            // 3. 디코딩된 지진 데이터 목록을 담은 원본 배열을 가져와 업데이트가 가능하도록 변수(var)에 복사합니다.
            var updatedQuakes = allQuakes.quakes

            // 4. 배열 내에서 특정 조건을 만족하는 '첫 번째 데이터의 인덱스'를 찾습니다.
            if let olderThanOneHour = updatedQuakes.firstIndex(where: {
                // 1970년 1월 1일로부터 3600초(1시간) 이상 지난 데이터인가를 검사합니다.
                // (일반적인 경우에는 $0.time.timeIntervalSinceNow < -3600 와 같은 방식을 더 자주 씁니다.)
                $0.time.timeIntervalSinceNow > 3600
            }) {

                // 5. 0번 인덱스(startIndex)부터 방금 찾은 인덱스(olderThanOneHour) 직전까지의 범위(Range)를 생성합니다.
                // (이 범위는 '최근 1시간 내의 지진 기록들'을 의미하게 됩니다.)
                let indexRange = updatedQuakes.startIndex..<olderThanOneHour

                // 6. 에러를 던질 수 있는 비동기 작업들을 병렬(Concurrent)로 처리하기 위해 TaskGroup을 만듭니다.
                // 이 TaskGroup이 완료될 때 반환할 데이터 타입은 `(Int, QuakeLocation)` 형태의 튜플입니다.
                try await withThrowingTaskGroup(of: (Int, QuakeLocation).self) { group in

                    // 7. 앞서 만든 최신 데이터 범위(최근 1시간치)를 반복문(for)으로 돕니다.
                    for index in indexRange {

                        // 8. TaskGroup에 지진 항목마다 독립적인 비동기 작업을 추가(실행)합니다.
                        group.addTask {

                            // 9. 개별 지진 데이터가 갖고 있는 상세 URL(detail)을 통해 해당 지진의 구체적인 위치(Location)를 네트워크로 가져옵니다.
                            let location = try await self.quakeLocation(
                                from: allQuakes.quakes[index].detail
                            )

                            // 10. 네트워크 응답이 성공하면 지진의 원래 배열 인덱스(index)와 새로 가져온 위치 정보(location)를 짝지어 반환합니다.
                            return (index, location)
                        }
                    }

                    // 11. 병렬로 요청했던 각각의 작업(Task)들이 끝나는 대로 그 결과(튜플 데이터)를 순서대로 하나씩 꺼내옵니다.
                    while let result = await group.nextResult() {
                        switch result {

                        // 12. 만약 작업 중 하나라도 네트워크 에러나 파싱 에러 등으로 실패했다면 다른 작업을 멈추고 에러를 밖으로 던집니다.
                        case .failure(let error):
                            throw error

                        // 13. 개별 작업이 성공해서 `(index, location)` 튜플 데이터를 제대로 받아왔다면,
                        case .success(let (index, location)):

                            // 14. 복사해두었던 배열(`updatedQuakes`)의 해당 인덱스(.location) 위치에 방금 가져온 디테일한 위치 값을 채워 넣습니다.
                            updatedQuakes[index].location = location
                        }
                    }
                }
            }

            // 15. 추가적인 상세 위치 정보가 모두 채워진(최근 1시간 이내 건들만) 최종 지진 데이터 배열을 반환합니다.
            return updatedQuakes
        }
    }

    init(downloader: any HTTPDataDownloader = URLSession.shared) {
        self.downloader = downloader
    }

    func quakeLocation(from url: URL) async throws -> QuakeLocation {
        if let cached = quakeCache[url] {
            switch cached {
            case .inProgress(let task):
                return try await task.value
            case .ready(let quakeLocation):
                return quakeLocation
            }
        }
        let task = Task<QuakeLocation, Error> {
            let data = try await downloader.httpData(from: url)
            let location = try decoder.decode(QuakeLocation.self, from: data)
            return location
        }
        quakeCache[url] = .inProgress(task)
        do {
            let location = try await task.value
            quakeCache[url] = .ready(location)
            return location
        } catch {
            quakeCache[url] = nil
            throw error
        }
    }
}
