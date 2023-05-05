//
//  Contributors View.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import SwiftUI

struct ContributorsView: View
{
    
    @State var contributor: Contributor
    
    var body: some View
    {
        VStack(alignment: .center, spacing: 10)
        {
            AsyncImage(url: contributor.avatarLink)
            { image in
                image
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } placeholder: {
                ProgressView()
                    .frame(width: 100, height: 100)
            }

            VStack(alignment: .center, spacing: 5)
            {
                Text(contributor.name)
                    .bold()
                Text(contributor.reasonForAcknowledgement)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
    }
}
