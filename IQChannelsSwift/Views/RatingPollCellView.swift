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
        return IQStyle.getColor(theme: IQStyle.model?.rating?.backgroundContainer?.color) ?? Color(hex: "F4F4F8")
    }
    var backgroundRadius: CGFloat {
        return IQStyle.model?.rating?.backgroundContainer?.border?.borderRadius ?? 12
    }
    var backgroundBorderSize: CGFloat {
        return IQStyle.model?.rating?.backgroundContainer?.border?.size ?? 0
    }
    var backgroundBorderColor: Color {
        return IQStyle.getColor(theme: IQStyle.model?.rating?.backgroundContainer?.border?.color) ?? Color(hex: "000000")
    }
    
    
    
    
    var titleColor: Color {
        return IQStyle.getColor(theme: IQStyle.model?.rating?.ratingTitle?.color) ?? Color(hex: "242729")
    }
    var titleFontSize: CGFloat {
        return CGFloat(IQStyle.model?.rating?.ratingTitle?.textSize ?? 17)
    }
    var titleIsBold: Bool {
        return IQStyle.model?.rating?.ratingTitle?.textStyle?.bold ?? false
    }
    var titleIsItalic: Bool {
        return IQStyle.model?.rating?.ratingTitle?.textStyle?.italic ?? false
    }
    var titleAlignment: TextAlignment {
        return stringToAlignment(stringAlignment: IQStyle.model?.rating?.ratingTitle?.textAlign) ?? .leading
    }
    
    
    
    var thanksColor: Color {
        return IQStyle.getColor(theme: IQStyle.model?.rating?.feedbackThanksText?.color) ?? Color(hex: "242729")
    }
    var thanksFontSize: CGFloat {
        return CGFloat(IQStyle.model?.rating?.feedbackThanksText?.textSize ?? 17)
    }
    var thanksIsBold: Bool {
        return IQStyle.model?.rating?.feedbackThanksText?.textStyle?.bold ?? false
    }
    var thanksIsItalic: Bool {
        return IQStyle.model?.rating?.feedbackThanksText?.textStyle?.italic ?? false
    }
    var thanksAlignment: TextAlignment {
        return stringToAlignment(stringAlignment: IQStyle.model?.rating?.feedbackThanksText?.textAlign) ?? .leading
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
                    if #available(iOS 16.0, *) {
                        Text(IQLanguageTexts.model.ratingOfferTitle ?? "Желаете пройти опрос?")
                            .foregroundColor(titleColor)
                            .font(.system(size: titleFontSize))
                            .bold(titleIsBold)
                            .italic(titleIsItalic)
                            .multilineTextAlignment(titleAlignment)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity, alignment: textAlignmentToAlignment(textAlignment: titleAlignment) ?? .center)
                    } else {
                        Text(IQLanguageTexts.model.ratingOfferTitle ?? "Желаете пройти опрос?")
                            .foregroundColor(titleColor)
                            .font(.system(size: titleFontSize))
                            .multilineTextAlignment(titleAlignment)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity, alignment: textAlignmentToAlignment(textAlignment: titleAlignment) ?? .center)
                    }
                    OfferView() { value in
                        needShowOffer = false
                        needPoll = value
                        if(!value){
                            onSendPollConversation?(nil, [], rating.id, ratingPoll.id, false)
                        }
                    }
                }
                
                else if wasLastQuestion && showThanks && needShowThanks {
                    if #available(iOS 16.0, *) {
                        Text(thanksText)
                            .foregroundColor(thanksColor)
                            .font(.system(size: thanksFontSize))
                            .bold(thanksIsBold)
                            .italic(thanksIsItalic)
                            .multilineTextAlignment(thanksAlignment)
                            .minimumScaleFactor(0.8)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    let ticketRatingValue = pollResult
                                        .filter { $0.asTicketRating == true }
                                        .compactMap { $0.answerStars ?? $0.answerScale }.first
                                    onSendPollConversation?(ticketRatingValue, pollResult, rating.id, ratingPoll.id, true)
                                    pollResult = []
                                }
                            }
                    } else {
                        Text(thanksText)
                            .foregroundColor(thanksColor)
                            .font(.system(size: thanksFontSize))
                            .multilineTextAlignment(thanksAlignment)
                            .minimumScaleFactor(0.8)
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
                }
                
                else if !wasLastQuestion {
                    if #available(iOS 16.0, *) {
                        Text(textPoll)
                            .foregroundColor(titleColor)
                            .font(.system(size: titleFontSize))
                            .bold(titleIsBold)
                            .italic(titleIsItalic)
                            .multilineTextAlignment(titleAlignment)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity, alignment: textAlignmentToAlignment(textAlignment: titleAlignment) ?? .center)
                    } else {
                        Text(textPoll)
                            .foregroundColor(titleColor)
                            .font(.system(size: titleFontSize))
                            .multilineTextAlignment(titleAlignment)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity, alignment: textAlignmentToAlignment(textAlignment: titleAlignment) ?? .center)
                    }
                    
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
                            Text("Rating error!")
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
            .cornerRadius(backgroundRadius)
            .overlay(
                RoundedRectangle(cornerRadius: backgroundRadius)
                    .stroke(backgroundBorderColor, lineWidth: backgroundBorderSize)
            )
        }
    }
}
