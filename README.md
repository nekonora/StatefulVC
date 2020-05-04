# StatefulVC

## Info

This is a simple MVVM-based reactive-whatever architecture bundle for iOS built upon UIKit and Combine.

## Import

You can import this as a SPM package in Xcode:

```
https://github.com/nekonora/StatefulVC.git
```

## Example

Let's say we have a scene that needs to display a collection of books from an author. These books could be as well retrieved from an external service.

Every view model has `config` and `data` properties of the type defined by its class's generics. `data` is self-explanatory: it's the data the scene is going to manage/display. `config` is any other possible data type that could be used to configure the scene.

We create subclasses of `StatefulVC` and `StatefulVM`, specifying the types of `config` and `data`:

```swift
class BooklistVM: StatefulVM<Config, [Book]> { ... }

class BooklistVC: StatefulVC<Config, [Book], BooklistVM> { ... }
```

We then create an instance of the scene like this:

```swift
let booklistVC = BoolistVC.instance(with: BooklistVM(config: config, data: author.books))
```

or (if you like to use storyboards):

```swift
let booklistVC = BoolistVC.storyboardInstance(with: BooklistVM(config: config, data: author.books))
```

In our view model, we can override the `bindSubscriptions()` method to provide our implementation of how the view controller's view should be updated. For example, let's say that some service or method updates the array of books stored in `data`: we can update the view accordingly by calling `updateViewState()`:

```swift
/// In BooklistVM

override func bindSubscriptions() {
    $data
        .dropFirst()
        .sink { self.updateViewState(.data($0)) }
        .store(in: &subscriptions)
}
```

We then decide what the view should do when the `data` state is set:

```swift
/// In BooklistVC

override func onStateData(data: [Book]) {
    applyDataSnapshot(data)
}
```

Done!

You can look at the tests for an example of how this is intended to work.
