//
//  기억력 게임 스크린[기상 미션]
//  Created by 이해주 on 2022/01/09.
//

import SwiftUI

struct MemorizeGameScreen: View {
    @ObservedObject var game: Memorize
    @State var gameRound: Int = 3
    var body: some View {
        NavigationView {
            ZStack {
                Color.darkBackground.ignoresSafeArea()
                GeometryReader { g in
                    VStack() {
                        Text("SHUFFLE")
                            .responsiveTextify(14, .bold)
                            .onTapGesture {
                                game.shuffleCard()
                            }
                        GameNumIndicator()
                        AspectVGrid(ScreenStyle.aspectRatio, game.cards) { item in
                            if item.isMatched {
                                Rectangle().opacity(0.0)
                            } else {
                                CardView(card:item)
                                    .onTapGesture {
                                        withAnimation {
                                            game.chooseCard(item)
                                        }
                                    }
                            }
                        }
                        TimeIndicator(geometry: g)
                    }
                }.padding()
            }
            .hiddenNavBarStyle()
        }
    }
    
    private struct ScreenStyle {
        static let aspectRatio: CGFloat = 98/127
        static let cardSize: CGFloat = 100
        static let horizonPad: CGFloat = 20
    }
}


//MARK: - 타이머 로직
/*
 1. 기본 타이머 5분
 2. 시간이 종료되면 매칭된 카드들이 해제되고 카드가 섞임, 이후 타이머도 기본 설정값으로 리셋됨.
 3. '+' 버튼을 클릭하면 타이머 시간이 10초 연장됨. (횟수 제한 없음)
 */

struct TimeIndicator: View {
    @State var geometry: GeometryProxy
    @State var timeRemaining = 180
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let roundShape = RoundedRectangle(cornerRadius: 50)
    var body: some View {
        HStack {
            // Timer Text Text
            ZStack {
                Text(remainTime())
                    .responsiveTextify(14, .bold)
                    .onReceive(timer) { _ in
                        computeReaminTiem()
                    }
            }
            .frame(minWidth: 0, maxWidth: Style.tWrapperWidth, minHeight: Style.tWrapperHeight)
            // Progress Bar
            ZStack(alignment: .leading) {
                roundShape
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 6, alignment: .leading)
                    .foregroundColor(.white)
                roundShape
                    .frame(minWidth: 0, maxWidth: countRatio(), maxHeight: 6, alignment: .topLeading)
                    .foregroundColor(.brandColor)
                    .animation(Animation.linear, value: countRatio())
            }
        }
    }
    // 차감된 시간 비율을 기준으로 ProgressBar 넓이를 계산
    private func countRatio()-> CGFloat {
        return geometry.size.width * (Double(timeRemaining) / Style.remainTime)
    }
    
    // 남은 시간을 보여주는 Text Indicator
    private func remainTime() -> String {
        return "\(timeRemaining/60)분 \(timeRemaining % 60)초"
    }
    
    // 남은 시간을 계산하는 로직
    private func computeReaminTiem () {
        // 남은 시간이 0보다 클 때 아래 연산 진행
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            // 타이머 리셋
            timeRemaining = Int(Style.remainTime)
        }
    }
    
    struct Style {
        static let remainTime: Double = 180
        static let textScale:CGFloat = 14
        static let tWrapperWidth: CGFloat = 50
        static let tWrapperHeight: CGFloat = 40
    }
}



// 기억력 카드 게임에서 사용되는 카드 뷰
struct CardView: View {
    var card: Memorize.Card
    var body: some View {
        ZStack {
            Text(card.content).cardify(isSelected: card.isSelected)
        }
    }
}


// 게임 횟수를 보여주는 인디케이터
struct GameNumIndicator: View {
    var body: some View {
        HStack {
            Spacer()
            ZStack {
                Text("1/3").responsiveTextify(IndicatorStyle.textScale, .medium)
            }
            .roundRectify(IndicatorStyle.radius, .center)
            .frame(width: IndicatorStyle.width, height: IndicatorStyle.height)
        }
    }
    
    private struct IndicatorStyle {
        static let textScale: CGFloat = 24
        static let radius: CGFloat = 12
        static let width: CGFloat = 90
        static let height: CGFloat = 47
        
    }
}



