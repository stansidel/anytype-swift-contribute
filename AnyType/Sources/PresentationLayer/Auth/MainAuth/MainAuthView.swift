import SwiftUI


struct MainAuthView: View {
    @ObservedObject var viewModel: MainAuthViewModel
    @State private var showLoginView: Bool = false
    
    var body: some View {
        ZStack {
            Image("mainAuthBackground")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                Image("logo")
                    .padding(.leading, 20)
                    .padding(.top, 30)
                Spacer()
                VStack {
                    Text("Organize everything")
                        .padding(20)
                        .font(.title)
                    Text("OrganizeEverythingDescription")
                        .padding([.leading, .trailing, .bottom], 20)
                    
                    HStack(spacing: 0) {
                        NavigationLink(destination: viewModel.showCreateProfileView(),
                                       isActive: $viewModel.shouldShowCreateProfileView) {
                            EmptyView()
                        }
                        StandardButton(disabled: false, text: "Sign up", style: .white) {
                            self.viewModel.singUp()
                        }
                        .padding(.trailing, 12)
                        
                        NavigationLink(destination: viewModel.showLoginView(), isActive: $showLoginView) {
                            EmptyView()
                        }
                        StandardButton(disabled: false, text: "Login", style: .yellow) {
                            self.showLoginView = true
                        }
                    }
                    .padding([.leading, .trailing], 20)
                    .padding(.bottom, 16)
                }
                .background(Color.white)
                .cornerRadius(12.0)
                .padding(20)
            }
            .errorToast(isShowing: $viewModel.isShowingError, errorText: viewModel.error)
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        .embedInNavigation()
    }
}


#if DEBUG
struct MainAuthView_Previews : PreviewProvider {
    
    static var previews: some View {
        MainAuthView(viewModel: MainAuthViewModel())
    }
}
#endif
