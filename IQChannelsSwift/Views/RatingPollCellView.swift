//
//  RatingPollCellView.swift
//  Pods
//
//  Created by Mikhail Zinkov on 01.12.2024.
//

import SwiftUI
import SDWebImageSwiftUI

private var pollResult: [IQRatingPollClientAnswerInput] = []

struct RatingPollCellView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    let rating: IQRating
    let ratingPoll: IQRatingPoll
    let onSendPollConversation: ((Int?, [IQRatingPollClientAnswerInput], Int, Int, Bool) -> Void)?
    
    @State private var currentQuestionIndex: Int = 0
    @State private var selectedRating: Int? = nil
    @State private var needShowOffer: Bool = true
    @State private var needShowThanks: Bool = true
    @State private var needPoll: Bool = true
    
    var cellWidth: CGFloat {
        return UIScreen.screenWidth - 50
    }
    
    var graduationWidth: CGFloat {
        return min(50, (cellWidth - CGFloat(graduationCount) * 5) / CGFloat(graduationCount))
    }
    
    var starWidth: CGFloat {
        return min(50, (cellWidth - 50) / 5)
    }
    
    var backgroundColor: Color {
        return Style.getColor(theme: Style.model?.rating?.backgroundContainer) ?? Color(hex: "F4F4F8")
    }
    
    var textColor: Color {
        return Style.getColor(theme: Style.model?.rating?.text?.color) ?? Color(hex: "242729")
    }
    
    var textFontSize: CGFloat {
        return CGFloat(Style.model?.rating?.text?.textSize ?? 17)
    }
    
    var textPoll: String {
        return ratingPoll.questions?[currentQuestionIndex].text ?? ""
    }
    
    var minValue: Int {
        return ratingPoll.questions?[currentQuestionIndex].scale?.fromValue ?? 0
    }
    
    var maxValue: Int {
        return ratingPoll.questions?[currentQuestionIndex].scale?.toValue ?? 10
    }
    
    var graduationCount: Int {
        return maxValue - minValue + 1
    }
    
    var minValueText: String {
        return ratingPoll.questions?[currentQuestionIndex].scale?.items?["\(minValue)"] ?? ""
    }
    
    var maxValueText: String {
        return ratingPoll.questions?[currentQuestionIndex].scale?.items?["\(maxValue)"] ?? ""
    }
    
    var questionType: IQRatingQuestionType {
        return ratingPoll.questions?[currentQuestionIndex].type ?? .scale
    }
    
    var wasLastQuestion: Bool {
        return ratingPoll.questions?.count == currentQuestionIndex
    }
    
    var showOffer: Bool {
        return ratingPoll.showOffer
    }
    
    var showThanks: Bool {
        return ratingPoll.feedbackThanks
    }
    
    var thanksText: String {
        return ratingPoll.feedbackThanksText
    }
    
    // MARK: - BODY
    var body: some View {
        if needPoll{
            VStack(spacing: 12) {
                if showOffer && needShowOffer {
                    Text("Желаете пройти опрос?")
                        .foregroundColor(textColor)
                        .font(.system(size: textFontSize))
                        .minimumScaleFactor(0.8)
                        .lineLimit(2)
                    OfferView() { value in
                        needShowOffer = false
                        needPoll = value
                        if(!value){
                            onSendPollConversation?(nil, [], rating.id, ratingPoll.id, false)
                        }
                    }
                }
                
                else if wasLastQuestion && showThanks && needShowThanks {
                    Text(thanksText)
                        .foregroundColor(textColor)
                        .font(.system(size: textFontSize))
                        .minimumScaleFactor(0.8)
                        .lineLimit(2)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                let ticketRatingValue = pollResult
                                    .filter { $0.asTicketRating == true }
                                    .compactMap { $0.answerStars ?? $0.answerScale }.first
                                onSendPollConversation?(ticketRatingValue, pollResult, rating.id, ratingPoll.id, true)
                                pollResult = []
                            }
                        }
                }
                
                else if !wasLastQuestion {
                    Text(textPoll)
                        .foregroundColor(textColor)
                        .font(.system(size: textFontSize))
                        .minimumScaleFactor(0.8)
                        .lineLimit(2)
                    
                    switch questionType {
                    case .scale:
                        ScaleView(rating: rating,
                                  ratingPoll: ratingPoll,
                                  currentQuestionIndex: currentQuestionIndex,
                                  graduationWidth: graduationWidth) { value in
                            pollResult.append(value)
                            currentQuestionIndex += 1
                        }
                    case .oneOfList:
                        OneOfListView(rating: rating,
                                      ratingPoll: ratingPoll,
                                      currentQuestionIndex: currentQuestionIndex) { value in
                            pollResult.append(value)
                            currentQuestionIndex += 1
                        }
                    case .input:
                        InputView(rating: rating,
                                  ratingPoll: ratingPoll,
                                  currentQuestionIndex: currentQuestionIndex) { value in
                            pollResult.append(value)
                            currentQuestionIndex += 1
                        }
                    case .stars:
                        StarsView(rating: rating,
                                  ratingPoll: ratingPoll,
                                  currentQuestionIndex: currentQuestionIndex,
                                  starWidth: starWidth) { value in
                            pollResult.append(value)
                            currentQuestionIndex += 1
                        }
                    case .fcr:
                        FCRView(rating: rating,
                                ratingPoll: ratingPoll,
                                currentQuestionIndex: currentQuestionIndex) { value in
                            pollResult.append(value)
                            currentQuestionIndex += 1
                        }
                    case .invalid:
                        Text("Ошибка опроса!")
                    }
                }else{
                    Text("").onAppear() {
                        let ticketRatingValue = pollResult
                            .filter { $0.asTicketRating == true }
                            .compactMap { $0.answerStars ?? $0.answerScale }.first
                        onSendPollConversation?(ticketRatingValue, pollResult, rating.id, ratingPoll.id, true)
                        pollResult = []
                        needPoll = false
                    }
                }
            }
            .frame(width: cellWidth)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(backgroundColor)
            .cornerRadius(12)
        }
    }
}
