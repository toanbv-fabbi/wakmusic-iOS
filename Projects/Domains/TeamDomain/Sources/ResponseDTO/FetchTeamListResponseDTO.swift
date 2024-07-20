import Foundation
import TeamDomainInterface

public struct FetchTeamListResponseDTO: Decodable {
    public let team: String
    public let name: String
    public let position: String
    public let profile: String
    public let isLead: Bool
}

public extension FetchTeamListResponseDTO {
    func toDomain() -> TeamListEntity {
        return .init(
            team: team,
            name: name,
            position: position,
            profile: profile,
            isLead: isLead
        )
    }
}