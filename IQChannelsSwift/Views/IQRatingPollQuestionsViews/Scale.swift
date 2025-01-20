//
//  Scale.swift
//  Pods
//
//  Created by Mikhail Zinkov on 05.12.2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct ScaleView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    let rating: IQRating
    let ratingPoll: IQRatingPoll
    let currentQuestionIndex: Int
    let graduationWidth: CGFloat
    let questionAnswered: ((IQRatingPollClientAnswerInput) -> Void?)
    
    @State private var selectedRating: Int? = nil
    
    
    var textColor: Color {
        return Style.getColor(theme: Style.model?.rating?.text?.color) ?? Color(hex: "242729")
    }
    
    var textFontSize: CGFloat {
        return CGFloat(Style.model?.rating?.text?.textSize ?? 17)
    }
    
    var ratingPollQuestionId: Int {
        return ratingPoll.questions?[currentQuestionIndex].id ?? 0
    }
    
    var minValue: Int {
        return ratingPoll.questions?[currentQuestionIndex].scale?.fromValue ?? 0
    }
    
    var maxValue: Int {
        return ratingPoll.questions?[currentQuestionIndex].scale?.toValue ?? 10
    }
    
    var minValueText: String {
        return ratingPoll.questions?[currentQuestionIndex].scale?.items?["\(minValue)"] ?? ""
    }
    
    var maxValueText: String {
        return ratingPoll.questions?[currentQuestionIndex].scale?.items?["\(maxValue)"] ?? ""
    }
    
    var asTicketRating: Bool {
        return ratingPoll.questions?[currentQuestionIndex].asTicketRating ?? false
    }
    
    
    // MARK: - BODY
    var body: some View {
        let enabledRatingTextColor = Style.getColor(theme: Style.model?.rating?.sentRating?.textEnabled?.color) ?? Color.white
        let disabledRatingTextColor = Style.getColor(theme: Style.model?.rating?.sentRating?.textDisabled?.color) ?? Color.white
        let enabledRatingFontSize = CGFloat(Style.model?.rating?.sentRating?.textEnabled?.textSize ?? 15)
        let disabledRatingFontSize = CGFloat(Style.model?.rating?.sentRating?.textDisabled?.textSize ?? 15)
        let enabledRatingBackgroundColor = Style.getColor(theme: Style.model?.rating?.sentRating?.backgroundEnabled) ?? Color(hex: "DD0A34")
        let disabledRatingBackgroundColor = Style.getColor(theme: Style.model?.rating?.sentRating?.backgroundDisabled) ?? Color(hex: "B7B7CA")
        
        HStack(spacing: 5) {
            ForEach(minValue...maxValue, id: \.self) { i in
                Button {
                    selectedRating = i
                } label: {
                    if i == selectedRating {
                        Text("\(i)")
                            .font(.system(size: textFontSize))
                            .foregroundColor(enabledRatingTextColor)
                            .frame(width: graduationWidth, height: graduationWidth*1.4)
                            .background(
                                RoundedRectangle(cornerRadius: 7)
                                    .fill(enabledRatingBackgroundColor)
                            )
                    } else {
                        Text("\(i)")
                            .font(.system(size: textFontSize))
                            .foregroundColor(textColor)
                            .frame(width: graduationWidth, height: graduationWidth*1.4)
                            .background(
                                RoundedRectangle(cornerRadius: 7)
                                    .fill(Color.gray.opacity(0.2))
                            )
                    }
                }
            }
        }
        HStack() {
            Text(minValueText)
                .font(.system(size: textFontSize))
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            Text(maxValueText)
                .font(.system(size: textFontSize))
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .multilineTextAlignment(.trailing)
        }
        
        
        Button {
            if let selectedRating {
                questionAnswered(IQRatingPollClientAnswerInput(projectId: rating.projectID ?? 0,
                                                               clientId: rating.clientID ?? 0,
                                                               ratingId: rating.id,
                                                               ratingPollQuestionId: ratingPollQuestionId,
                                                               type: .scale,
                                                               fcr: nil,
                                                               ratingPollAnswerId: nil,
                                                               answerInput: nil,
                                                               answerStars: nil,
                                                               answerScale: selectedRating,
                                                               asTicketRating: asTicketRating))
            }
        } label: {
            Text("Отправить")
                .foregroundColor(selectedRating == nil ? disabledRatingTextColor : enabledRatingTextColor)
                .font(.system(size: selectedRating == nil ? disabledRatingFontSize : enabledRatingFontSize))
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background(selectedRating == nil ? disabledRatingBackgroundColor : enabledRatingBackgroundColor)
                .cornerRadius(8)
        }
        .disabled(selectedRating == nil)
    }
}
