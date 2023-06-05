//
//  Post Post.swift
//  Mlem
//
//  Created by David Bureš on 22.05.2023.
//

import Foundation
import SwiftUI

internal enum PostPostingFailure: Error
{
    case couldNotPost, receivedInvalidServerResponse, couldNotParseNewPost
}

func postPost(to community: Community, postTitle: String, postBody: String, postURL: String, postIsNSFW: Bool, postTracker: PostTracker, account: SavedAccount, appState: AppState) async throws
{
    
    do
    {
        var createPostCommandBody: [String: Any] = [
            "community_id": community.id,
            "name": postTitle,
            "nsfw": postIsNSFW
        ]
        
        if !postBody.isEmpty
        {
            createPostCommandBody.append("body", postBody)
        }
        if !postURL.isEmpty
        {
            createPostCommandBody.append("url", postURL)
        }
        
        let postPostingCommandResult: String = try await sendPostCommand(appState: appState, account: account, endpoint: "post", arguments: createPostCommandBody)
        
        print("Successfuly posted post: \(postPostingCommandResult)")

        if !postPostingCommandResult.contains("\"error\"")
        {
            do
            {
                let postedPost: Post = try await parsePosts(postResponse: postPostingCommandResult, instanceLink: account.instanceLink).first!
                
                withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 1, blendDuration: 0.4))
                {
                    postTracker.posts.prepend(postedPost)
                }
            }
            catch let newPostParsingError
            {
                print("Failed while parsing new post: \(newPostParsingError)")
                
                appState.alertTitle = "Couldn't read updated posts"
                appState.alertMessage = "Refresh your feed to see the new post."
                appState.isShowingAlert.toggle()
                
                throw PostPostingFailure.couldNotParseNewPost
            }
        }
        else
        {
            print("Received error from the server")
            
            appState.alertTitle = "Received unexpected response from Lemmy"
            appState.alertMessage = "Mlem received unexpected data.\nTry restarting the app and posting again."
            appState.isShowingAlert.toggle()

            throw PostPostingFailure.receivedInvalidServerResponse
        }
    }
    catch let postPostingError
    {
        print("Failed while posting post: \(postPostingError)")
        
        appState.alertTitle = "Couldn't create post"
        appState.alertMessage = "Restart Mlem and try again."
        appState.isShowingAlert.toggle()

        throw PostPostingFailure.couldNotPost
    }
}
