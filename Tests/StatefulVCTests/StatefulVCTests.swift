import XCTest
@testable import StatefulVC

private class TestVM: StatefulVM<(String, Int), [String]> {
    
    override func bindSubscriptions() {
        $data
            .dropFirst()
            .sink { if let newData = $0 { self.updateViewState(to: .data(data: newData)) } }
            .store(in: &subscriptions)
    }
    
    func successCall(with data: [String]) {
        self.data = data
    }
    
    func failCall() {
        updateViewState(to: .error)
    }
}

private class TestVC: StatefulVC<(String, Int), [String], TestVM> {
    
    var viewUpdate: XCTestExpectation?
    
    @Published var receivedData = [String]()
    var hasError = false
    
    override func onStateInitial() {
        $receivedData
            .dropFirst()
            .sink { _ in self.viewUpdate?.fulfill() }
            .store(in: &model.subscriptions)
    }
    
    override func onStateData(data: [String]) { receivedData = data }
    
    override func onStateError() { hasError = true }
}

final class StatefulVCTests: XCTestCase {
    
    // MARK: - Test objects
    
    private var testVC: TestVC?
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        testVC = TestVC.instance(with: TestVM(config: ("config", 111), initialData: ["data1", "data2"]))
        testVC?.viewDidLoad()
    }
    
    // MARK: - Tests
    
    func testControllerExists() { XCTAssertNotNil(testVC) }
    
    func testViewModelHasConfig() { XCTAssertNotNil(testVC?.model.config) }
    
    func testViewModelHasData() { XCTAssertNotNil(testVC?.model.data) }
    
    func testUpdateDataSuccess() {
        let expectation = XCTestExpectation(description: "Data has been updated")
        testVC?.viewUpdate = expectation
        
        /// View model receives data
        testVC?.model.successCall(with: ["newData"])
        
        /// View has been updated
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(testVC?.receivedData, ["newData"])
    }
    
    func testUpdateDataFail() {
        /// View model fails data call
        testVC?.model.failCall()
        
        /// View is in error state
        if case .error = testVC?.state {
            XCTAssert(true)
        } else {
            XCTFail("Incorrect state")
        }
    }
}
