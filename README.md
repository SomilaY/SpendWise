# SpendWise

SpendWise is a personal expense tracker for Apple platforms. It lets you record expenses, review spending by month and category, and compare monthly spending with a budget.

## Features

- Add, edit, and delete expenses.
- Categorize spending as Food, Transport, Shopping, Bills, Entertainment, or Other.
- Browse expenses and summaries by month.
- View monthly totals, category totals, and a short insight about the largest spending category.
- Set a monthly budget and see progress reflected in the dashboard.
- Store expenses locally with SwiftData. Currency values use the device's locale, with ZAR as a fallback.

## Requirements

- Xcode
- An Apple platform SDK supported by the project

## Run the app

1. Open `SpendWise.xcodeproj` in Xcode.
2. Select the **SpendWise** scheme and an available simulator or device.
3. Build and run the app with **Product > Run** (⌘R).

## Using SpendWise

Tap **+** to enter an expense with a title, amount, category, and date. Tap an existing transaction to edit it; swipe a transaction to delete it. Use the month picker to change the period shown, and open the budget settings from the dashboard to update your monthly budget.

Expenses are saved on the device using SwiftData. The monthly budget is stored in app preferences.

## Project layout

- `SpendWise/SpendWise/Models`: expense model and categories
- `SpendWise/SpendWise/ViewModels`: expense totals and insights
- `SpendWise/SpendWise/Views`: dashboard, forms, charts, and reusable UI
- `SpendWise/SpendWise/Utilities`: formatting, theme, and view utilities
