//
//  DiaryViewModel.swift
//  Diary
//
//  Created by Aaron, Gundy, Rhovin on 2023/01/11.
//

import Foundation
// 일을 시키기만 한다. 보여주기 위한 포매팅만 한다.
// view를 위해 model의 값을 손질함. 다만 직접 view를 변경하진 않고 뷰가 변경 로직을 가져감.
// data binding - 내가 할 수 없는 일은 남에게 부탁(메시지를 보낸다) - 내부 과정은 모르는 점에서 Protocol과 닮은 방식
final class DiaryViewModel {
    // 뷰컨을 안갖고 있다. 모른다는 것.
    private var diary: Diary {
        didSet {
            handler?(diary)
        }
    }

    private var handler: ((Diary) -> Void)?

    init(diary: Diary) {
        self.diary = diary
    }

    func bindDiary(handler: @escaping ((Diary) -> Void)) {
        self.handler = handler
    }
}

// 유저에 의한 이벤트
// 유저에 의하지 않은 이벤트
// 예: 카운터(숫자 스탭퍼같은 앱)에서 더하기 빼기 누르는 것은 유저가 일으킴. 뷰컨 입장에서는 뷰모델한테 시키면 됨.
// **유저에 의하지 않은 이벤트로 인해 뷰모델이 변화하면 뷰에게 알릴 방법은 무엇?**
// 옵저버 패턴이라거나 클로저로 주고받거나 노티, KVO, Delegation(delegate로 구현하려고 하면 실질적 MVP 패턴이 됨)
// 방식에 따라 장단점이 있다.
// 아키텍처는 역할을 어떻게 나눌까에 대해 고민하여 나온 객체지향적인 것.
