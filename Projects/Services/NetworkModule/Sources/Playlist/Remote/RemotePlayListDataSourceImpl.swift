import APIKit
import RxSwift
import DataMappingModule
import DomainModule
import ErrorModule
import Foundation


public final class RemotePlayListDataSourceImpl: BaseRemoteDataSource<PlayListAPI>, RemotePlayListDataSource {
   

    public func fetchRecommendPlayList() ->Single<[RecommendPlayListEntity]> {
        request(.fetchRecommendPlayList)
            .map([SingleRecommendPlayListResponseDTO].self)
            .map{$0.map{$0.toDomain()}}
   
    }
    
    public func fetchRecommendPlayListDetail(id: String) ->Single<[RecommendPlayListDetailEntity]> {
        request(.fetchRecommendPlayListDetail(id: id))
            .map([SingleRecommendPlayListDetailResponseDTO].self)
            .map{$0.map{$0.toDomain()}}
    }
    
   
    
    
    
  
    
 
}
