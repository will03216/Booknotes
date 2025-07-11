import SwiftUI


struct AutoGrowingTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var dynamicHeight: CGFloat

    let placeholder: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.delegate = context.coordinator
        textView.backgroundColor = UIColor.systemGray6
        textView.layer.cornerRadius = 6
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        textView.text = placeholder
        textView.textColor = .gray
        return textView
    } 

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text && uiView.textColor != .gray {
            uiView.text = text
        }

        AutoGrowingTextView.recalculateHeight(view: uiView, result: $dynamicHeight)

        // 控制 placeholder
        if text.isEmpty && uiView.isFirstResponder == false {
            uiView.text = placeholder
            uiView.textColor = .gray
        } else if uiView.textColor == .gray && uiView.isFirstResponder {
            uiView.text = ""
            uiView.textColor = .label
        }
    }

    func makeCoordinator() -> Coordinator {
        // 一定要把 dynamicHeight 和 placeholder 也传进来
        return Coordinator(
            text: $text,
            dynamicHeight: $dynamicHeight,
            placeholder: placeholder
        )
    }


    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        var dynamicHeight: Binding<CGFloat>
        let placeholder: String

        init(text: Binding<String>,
             dynamicHeight: Binding<CGFloat>,
             placeholder: String) {
            _text = text
            self.dynamicHeight = dynamicHeight
            self.placeholder = placeholder
        }

        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
            AutoGrowingTextView.recalculateHeight(view: textView, result: dynamicHeight)
            print("📝 textViewDidChange, binding text = '\(text)'")
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            // 把占位符清掉
            if textView.textColor == .gray {
                textView.text = ""
                textView.textColor = .label
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            text = textView.text
            AutoGrowingTextView.recalculateHeight(view: textView, result: dynamicHeight)
            print("🔒 textViewDidEndEditing, binding text = '\(text)'")
            if text.isEmpty {
                textView.text = placeholder
                textView.textColor = .gray
            }
        }
    }


    static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.bounds.width, height: .greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = newSize.height
            }
        }
    }
}

//

