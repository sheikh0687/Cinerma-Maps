//
//  SkeletonRowView.swift
//  Cinerama Maps
//
//  Created by Arbaz  on 30/04/26.
//

import SwiftUI

struct SkeletonLocdetailCard: View {
    
    var body: some View {
        LazyVStack(spacing: 0) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.gray.opacity(0.25))
                .frame(height: 180)
                .shimmer()

            VStack(alignment: .leading, spacing: 12) {
                // Title
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 16)
                    .shimmer()

                // Like/dislike + rating row
                HStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 120, height: 14)
                        .shimmer()
                    Spacer()
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 70, height: 14)
                        .shimmer()
                }

                // Location row
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 12)
                    .shimmer()

                // Description
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.25))
                        .frame(height: 12)
                        .shimmer()
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 200, height: 12)
                        .shimmer()
                }

                // Tag pills
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.25))
                            .frame(width: 70, height: 24)
                            .shimmer()
                    }
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 4)
        .padding(.vertical, 4)
        .padding(.horizontal, 16)
    }
}
