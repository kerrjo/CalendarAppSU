# CalendarAppSU
Calendar app SwiftUI, InspiringApps coding challenge

<img width="370" alt="Screen Shot 2022-02-02 at 9 29 48 AM" src="https://user-images.githubusercontent.com/12850537/152173740-a8e09fee-e175-4469-94e2-d3bbb151deb0.png">

## Usage
Built with *Xcode Version 13.2.1 (13C100)*

https://user-images.githubusercontent.com/12850537/152234218-e0395c79-ef4f-4882-bebf-cce55ebb8aae.mp4

# Apple suggests

In the Article _Managing Model Data in Your App_ in SwiftUI _State and Data Flow_, Create connections between your app’s data model and views.

## Make Model Data Observable
To make the data changes in your model visible to SwiftUI, adopt the ObservableObject protocol for model classes. For example, you can create a Book class that’s an observable object:
```
class Book: ObservableObject {
```
The system automatically infers the ObjectWillChangePublisher associated type for the class and synthesizes the required objectWillChange method that emits the changed values of published properties. To publish a property, add the Published attribute to the property’s declaration:
```
class Book: ObservableObject {
    @Published var title = "Great Expectations"
```
Avoid the overhead of a published property when you don’t need it. Only publish properties that both can change and that matter to the user interface. For example, the Book class might have an identifier property that never changes after initialization:
```
class Book: ObservableObject {
    @Published var title = "Great Expectations"
    let identifier = UUID() // A unique identifier that never changes.
```
You can still display the identifier in your user interface, but because it isn’t published, SwiftUI knows that it doesn’t have to watch that particular property for changes.

## Thats what i did

I made the view model adopt `ObservableObject` protocol and _published_ properties.

```
/**
 Model a calendar month, that allows changing to next and previous month
 retieves holidays from service
 
 */
class MonthViewModel: ObservableObject, MonthViewing {
    
    @Published var numberOfDaysInMonth: Int = 0
    @Published var yearMonthTitle: String = ""
    @Published var startDay: Int = 0
    @Published var current: Int = 0
    @Published var year: Int = 0
    @Published var dayViewModels: [WeekViewModel] = []
    
    private func update() {
        numberOfDaysInMonth = monthCalculator.numberOfDaysInMonth
        current = monthCalculator.mdyValues.0
        year = monthCalculator.mdyValues.2
        startDay = monthCalculator.startDayOfWeek
        yearMonthTitle = "\(year)  " + monthName
        dayViewModels = []
        generateDayModels()
    }
```

And passed it around some SwiftUI views

it seems to work, well
