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
    let questionAnswered: ((IQRatingPollClientAnswerInput) -> Void)
    
    @State private var selectedRating: Int? = nil
    
    
    var minTextColor: Color {
        return IQStyle.getColor(theme: IQStyle.model?.rating?.scaleMinText?.color) ?? Color(hex: "242729")
    }
    var minTextFontSize: CGFloat {
        return CGFloat(IQStyle.model?.rating?.scaleMinText?.textSize ?? 17)
    }
    var minTextIsBold: Bool {
        return IQStyle.model?.rating?.scaleMinText?.textStyle?.bold ?? false
    }
    var minTextIsItalic: Bool {
        return IQStyle.model?.rating?.scaleMinText?.textStyle?.italic ?? false
    }
    var minTextAligment: TextAlignment {
        return stringToAlignment(stringAlignment: IQStyle.model?.rating?.scaleMinText?.textAlign) ?? .leading
    }
    
    
    
    var maxTextColor: Color {
        return IQStyle.getColor(theme: IQStyle.model?.rating?.scaleMaxText?.color) ?? Color(hex: "242729")
    }
    var maxTextFontSize: CGFloat {
        return CGFloat(IQStyle.model?.rating?.scaleMaxText?.textSize ?? 17)
    }
    var maxTextIsBold: Bool {
        return IQStyle.model?.rating?.scaleMaxText?.textStyle?.bold ?? false
    }
    var maxTextIsItalic: Bool {
        return IQStyle.model?.rating?.scaleMaxText?.textStyle?.italic ?? false
    }
    var maxTextAligment: TextAlignment {
        return stringToAlignment(stringAlignment: IQStyle.model?.rating?.scaleMaxText?.textAlign) ?? .trailing
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
        let enabledScaleTextColor = IQStyle.getColor(theme: IQStyle.model?.rating?.scaleButton?.textEnabled?.color) ?? Color.white
        let disabledScaleTextColor = IQStyle.getColor(theme: IQStyle.model?.rating?.scaleButton?.textDisabled?.color) ?? Color.white
        let enabledScaleFontSize = CGFloat(IQStyle.model?.rating?.scaleButton?.textEnabled?.textSize ?? 15)
        let disabledScaleFontSize = CGFloat(IQStyle.model?.rating?.scaleButton?.textDisabled?.textSize ?? 15)
        let enabledScaleIsBold = IQStyle.model?.rating?.scaleButton?.textEnabled?.textStyle?.bold ?? false
        let disabledScaleIsBold = IQStyle.model?.rating?.scaleButton?.textDisabled?.textStyle?.bold ?? false
        let enabledScaleIsItalic = IQStyle.model?.rating?.scaleButton?.textEnabled?.textStyle?.italic ?? false
        let disabledScaleIsItalic = IQStyle.model?.rating?.scaleButton?.textDisabled?.textStyle?.italic ?? false
        
        let enabledScaleBackgroundColor = IQStyle.getColor(theme: IQStyle.model?.rating?.scaleButton?.backgroundEnabled?.color) ?? Color(hex: "DD0A34")
        let disabledScaleBackgroundColor = IQStyle.getColor(theme: IQStyle.model?.rating?.scaleButton?.backgroundDisabled?.color) ?? Color(hex: "B7B7CA")
        let enabledScaleRadius = IQStyle.model?.rating?.scaleButton?.backgroundEnabled?.border?.borderRadius ?? 7
        let disabledScaleRadius = IQStyle.model?.rating?.scaleButton?.backgroundDisabled?.border?.borderRadius ?? 7
        let enabledScaleBorderSize = IQStyle.model?.rating?.scaleButton?.backgroundEnabled?.border?.size ?? 0
        let disabledScaleBorderSize = IQStyle.model?.rating?.scaleButton?.backgroundDisabled?.border?.size ?? 0
        let enabledScaleBorderColor = IQStyle.getColor(theme: IQStyle.model?.rating?.scaleButton?.backgroundEnabled?.border?.color) ?? Color(hex: "000000")
        let disabledScaleBorderColor = IQStyle.getColor(theme: IQStyle.model?.rating?.scaleButton?.backgroundDisabled?.border?.color) ?? Color(hex: "000000")
        
        
        let enabledRatingTextColor = IQStyle.getColor(theme: IQStyle.model?.rating?.sentRating?.textEnabled?.color) ?? Color.white
        let disabledRatingTextColor = IQStyle.getColor(theme: IQStyle.model?.rating?.sentRating?.textDisabled?.color) ?? Color.white
        let enabledRatingFontSize = CGFloat(IQStyle.model?.rating?.sentRating?.textEnabled?.textSize ?? 15)
        let disabledRatingFontSize = CGFloat(IQStyle.model?.rating?.sentRating?.textDisabled?.textSize ?? 15)
        
        let enabledRatingBackgroundColor = IQStyle.getColor(theme: IQStyle.model?.rating?.sentRating?.backgroundEnabled?.color) ?? Color(hex: "DD0A34")
        let disabledRatingBackgroundColor = IQStyle.getColor(theme: IQStyle.model?.rating?.sentRating?.backgroundDisabled?.color) ?? Color(hex: "B7B7CA")
        let enabledRatingRadius = IQStyle.model?.rating?.sentRating?.backgroundEnabled?.border?.borderRadius ?? 8
        let disabledRatingRadius = IQStyle.model?.rating?.sentRating?.backgroundDisabled?.border?.borderRadius ?? 8
        let enabledRatingBorderSize = IQStyle.model?.rating?.sentRating?.backgroundEnabled?.border?.size ?? 0
        let disabledRatingBorderSize = IQStyle.model?.rating?.sentRating?.backgroundDisabled?.border?.size ?? 0
        let enabledRatingBorderColor = IQStyle.getColor(theme: IQStyle.model?.rating?.sentRating?.backgroundEnabled?.border?.color) ?? Color(hex: "000000")
        let disabledRatingBorderColor = IQStyle.getColor(theme: IQStyle.model?.rating?.sentRating?.backgroundDisabled?.border?.color) ?? Color(hex: "000000")
        
        let textAlignments: [TextAlignment: Alignment] = [
            .leading: Alignment.leading,
            .center: Alignment.center,
            .trailing: Alignment.trailing
        ]
        
        HStack(spacing: 5) {
            ForEach(minValue...maxValue, id: \.self) { i in
                Button {
                    selectedRating = i
                } label: {
                    if i == selectedRating {
                        if #available(iOS 16.0, *) {
                            Text("\(i)")
                                .font(.system(size: enabledScaleFontSize))
                                .bold(enabledScaleIsBold)
                                .italic(enabledScaleIsItalic)
                                .foregroundColor(enabledScaleTextColor)
                                .frame(width: graduationWidth, height: graduationWidth*1.4)
                                .background(enabledScaleBackgroundColor)
                                .cornerRadius(enabledScaleRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: enabledScaleRadius)
                                        .stroke(
                                            enabledScaleBorderColor,
                                            lineWidth: enabledScaleBorderSize)
                                )
                        } else {
                            Text("\(i)")
                                .font(.system(size: enabledScaleFontSize))
                                .foregroundColor(enabledScaleTextColor)
                                .frame(width: graduationWidth, height: graduationWidth*1.4)
                                .background(enabledScaleBackgroundColor)
                                .cornerRadius(enabledScaleRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: enabledScaleRadius)
                                        .stroke(
                                            enabledScaleBorderColor,
                                            lineWidth: enabledScaleBorderSize)
                                )
                        }
                    } else {
                        if #available(iOS 16.0, *) {
                            Text("\(i)")
                                .font(.system(size: disabledScaleFontSize))
                                .bold(disabledScaleIsBold)
                                .italic(disabledScaleIsItalic)
                                .foregroundColor(disabledScaleTextColor)
                                .frame(width: graduationWidth, height: graduationWidth*1.4)
                                .background(disabledScaleBackgroundColor)
                                .cornerRadius(disabledScaleRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: disabledScaleRadius)
                                        .stroke(
                                            disabledScaleBorderColor,
                                            lineWidth: disabledScaleBorderSize)
                                )
                        } else {
                            Text("\(i)")
                                .font(.system(size: disabledScaleFontSize))
                                .foregroundColor(disabledScaleTextColor)
                                .frame(width: graduationWidth, height: graduationWidth*1.4)
                                .background(disabledScaleBackgroundColor)
                                .cornerRadius(disabledScaleRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: disabledScaleRadius)
                                        .stroke(
                                            disabledScaleBorderColor,
                                            lineWidth: disabledScaleBorderSize)
                                )
                        }
                    }
                }
            }
        }
        HStack() {
            if #available(iOS 16.0, *) {
                Text(minValueText)
                    .font(.system(size: minTextFontSize))
                    .bold(minTextIsBold)
                    .italic(minTextIsItalic)
                    .foregroundColor(minTextColor)
                    .frame(maxWidth: .infinity, alignment: textAlignments[minTextAligment] ?? .leading)
                    .multilineTextAlignment(minTextAligment)
            } else {
                Text(minValueText)
                    .font(.system(size: minTextFontSize))
                    .foregroundColor(minTextColor)
                    .frame(maxWidth: .infinity, alignment: textAlignments[minTextAligment] ?? .leading)
                    .multilineTextAlignment(minTextAligment)
            }
            
            Spacer()
            
            if #available(iOS 16.0, *) {
                Text(maxValueText)
                    .font(.system(size: maxTextFontSize))
                    .bold(maxTextIsBold)
                    .italic(maxTextIsItalic)
                    .foregroundColor(maxTextColor)
                    .frame(maxWidth: .infinity, alignment: textAlignments[maxTextAligment] ?? .trailing)
                    .multilineTextAlignment(maxTextAligment)
            } else {
                Text(maxValueText)
                    .font(.system(size: maxTextFontSize))
                    .foregroundColor(maxTextColor)
                    .frame(maxWidth: .infinity, alignment: textAlignments[maxTextAligment] ?? .trailing)
                    .multilineTextAlignment(maxTextAligment)
            }
        }
        
        SentRatingButton(disabled: selectedRating == nil) {
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
    }
}
