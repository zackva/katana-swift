//
//  Reload.swift
//  HackerNewsClient
//
//  Copyright © 2016 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Katana

struct Reload: AsyncAction, ActionWithSideEffect {
    
    typealias LoadingPayload = ()
    typealias CompletedPayload = [Post]
    typealias FailedPayload = String
    
    var loadingPayload: LoadingPayload
    var completedPayload: CompletedPayload?
    var failedPayload: FailedPayload?
    
    var state: AsyncActionState = .loading
    
    init(payload: LoadingPayload) {
        self.loadingPayload = payload
    }
    
    static func updatedStateForLoading(currentState: State, action: Reload) -> State {
        var newState = currentState as! HackerNewsState
        newState.loading = true
        return newState
    }
    
    static func updatedStateForCompleted(currentState: State, action: Reload) -> State {
        var newState = currentState as! HackerNewsState
        newState.loading = false
        newState.posts = action.completedPayload!
        return newState
    }
    
    static func updatedStateForFailed(currentState: State, action: Reload) -> State {
        var newState = currentState as! HackerNewsState
        newState.loading = false
        return newState
    }
    
    static func sideEffect(
        action: Reload,
        state: State,
        dispatch: @escaping StoreDispatch,
        dependencies: SideEffectDependencyContainer) {
        
        let postsProvider = dependencies as! PostsProvider
        
        postsProvider.fetchPosts { (posts, error) in
            if let posts = posts {
                dispatch(action.completedAction(payload: posts))
            } else if let error = error {
                dispatch(action.failedAction(payload: error))
            }
        }
    }
}