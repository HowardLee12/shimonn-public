import SwiftUI

struct LegalView: View {
    var onNext: () -> Void
    
    // Checkbox states
    @State private var agreeToTerms = false
    @State private var understandNotWill = false
    
    var allAgreed: Bool {
        agreeToTerms && understandNotWill
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#F5F7FA").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Header
                Text("服務條款與免責聲明")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "#333333"))
                    .padding(.top, 20)
                
                // Content Card
                ScrollView {
                    VStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 16) {
                            
                            // Critical Warning
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 20))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("重要提醒")
                                        .font(.headline)
                                        .foregroundColor(.red)
                                    Text("請勿將此服務視為唯一的交代管道。本應用程式不具備法律遺囑效力。")
                                        .font(.system(size: 14))
                                        .foregroundColor(.red.opacity(0.8))
                                }
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                            
                            Text("歡迎使用 Shimonn")
                                .font(.headline)
                            Text("在使用本應用程式之前，請務必仔細閱讀以下條款。本服務僅作為輔助性質的訊息傳遞工具。")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#555555"))
                            
                            Divider()
                            
                            VStack(spacing: 0) {
                                ExpandableSection(title: "1. 服務性質與法律效力說明", content: """
                                • 非法律遺囑
                                本應用程式（Shimonn）所儲存、發送的任何訊息、文件或指示，均不具備民法上「遺囑」的法律效力。若您有財產分配、撫養權指定或其他具法律約束力的身後安排需求，請務必透過合格律師或公證人依照當地法律程序訂立正式遺囑。
                                
                                • 非緊急救援服務
                                本應用程式並非報警、醫療急救或自殺防治熱線的替代品。若您或他人處於立即的危險中，請立即撥打當地的緊急救助電話。
                                """)
                                
                                ExpandableSection(title: "2. 技術限制與免責條款", content: """
                                • 發送失敗風險
                                雖然我們致力於維持系統穩定，但受限於現有技術（如：iOS/Android 系統的背景執行限制、電池優化策略、網路訊號覆蓋範圍等），我們無法保證緊急訊息能在所有情況下 100% 成功觸發或送達。
                                
                                • 使用者裝置狀態
                                若因使用者手機沒電、遺失、損壞、未連接網路、或遭系統強制關閉背景執行權限，導致偵測機制失效，Shimonn 概不負責。
                                """)
                                
                                ExpandableSection(title: "3. 使用者責任與資料正確性", content: """
                                使用者有責任確保所設定的緊急聯絡人資訊正確且有效。若因資料過期或錯誤導致無法聯繫，後果由使用者自行承擔。建議使用者事先告知您的緊急聯絡人關於本服務的運作機制。
                                """)
                                
                                ExpandableSection(title: "4. 隱私權與加密機制", content: """
                                您的訊息內容在儲存時均經過加密處理。系統僅在觸發預設條件（如：倒數計時結束且未取消）時，才會進行解密並發送。我們絕不會將您的資料用於行銷或是出售給第三方。
                                """)
                                
                                ExpandableSection(title: "5. 禁止用途 & 服務變更", content: """
                                嚴禁使用本服務進行騷擾、恐嚇、詐騙、發送惡意程式，或宣揚自殺、自殘等違法行為。我們保留隨時修改、暫停或終止服務的權利。
                                """)
                            }
                        }
                        .padding()
                        
                        // Agreement Checkboxes
                        VStack(spacing: 12) {
                            CheckboxRow(isChecked: $agreeToTerms, text: "我已詳細閱讀並同意上述條款與隱私聲明")
                            CheckboxRow(isChecked: $understandNotWill, text: "我理解本服務**不具備**法律遺囑效力")
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                .frame(maxHeight: .infinity, alignment: .top)
                
                // Next Button
                Button(action: onNext) {
                    Text("下一步")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: allAgreed ? [Color(hex: "#4FACFE"), Color(hex: "#00F2FE")] : [Color.gray, Color.gray],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: allAgreed ? Color(hex: "#4FACFE").opacity(0.3) : Color.clear, radius: 10, x: 0, y: 5)
                }
                .disabled(!allAgreed)
                .padding(.horizontal, 32)
                .padding(.bottom, 20)
            }
        }
    }
}

// Helper Views
struct ExpandableSection: View {
    let title: String
    let content: String
    @State private var isExpanded = false
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                Text(content)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#555555"))
                    .lineSpacing(4)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            },
            label: {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "#333333"))
                    .padding(.vertical, 8)
            }
        )
        .accentColor(Color(hex: "#4FACFE"))
        .padding(.vertical, 4)
        Divider()
    }
}

struct CheckboxRow: View {
    @Binding var isChecked: Bool
    let text: String
    
    var body: some View {
        Button(action: { isChecked.toggle() }) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20))
                    .foregroundColor(isChecked ? Color(hex: "#4FACFE") : .gray)
                
                Text(.init(text)) // Using .init to support Markdown parsing for bold text
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#333333"))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
        }
    }
}

struct LegalView_Previews: PreviewProvider {
    static var previews: some View {
        LegalView(onNext: {})
    }
}
