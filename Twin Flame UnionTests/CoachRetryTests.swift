import Testing
import Foundation
@testable import The_Twin_Flame_Union_App

@MainActor
struct CoachRetryTests {

    /// A fake stream: first call throws, second call yields text. Records histories seen.
    final class FakeStream: ChatStreaming {
        var calls: [[ChatMessage]] = []
        var failFirst = true
        func streamMessage(history: [ChatMessage]) -> AsyncThrowingStream<String, Error> {
            calls.append(history)
            let shouldFail = failFirst && calls.count == 1
            return AsyncThrowingStream { cont in
                if shouldFail { cont.finish(throwing: URLError(.timedOut)) }
                else { cont.yield("Hello, soul."); cont.finish() }
            }
        }
    }

    @Test func retryResendsPreservedMessageWithoutRetyping() async {
        let fake = FakeStream()
        let vm = LoveCoachViewModel(service: fake)
        vm.inputText = "Will we reunite?"
        await vm.sendMessage()

        #expect(vm.canRetry == true)                       // first send failed
        #expect(vm.messages.contains { $0.role == .user && $0.content == "Will we reunite?" })

        await vm.retry()                                   // no retype
        #expect(vm.canRetry == false)
        // The retried call still carried the user's preserved message:
        #expect(fake.calls.last?.contains { $0.content == "Will we reunite?" } == true)
        #expect(vm.messages.last?.role == .assistant)
        #expect(vm.messages.last?.content == "Hello, soul.")
    }
}
