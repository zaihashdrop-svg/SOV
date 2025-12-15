# Shared Capital Loan System - Design Guidelines

## Design Approach
**System-Based Approach**: Inspired by **Stripe Dashboard** and **Plaid** for financial clarity, with Material Design principles for consistent, data-dense interfaces. This utility-focused financial application prioritizes trust, readability, and efficient information processing.

## Core Design Principles
1. **Financial Trust**: Professional, clean aesthetic that conveys security and reliability
2. **Data Clarity**: Clear hierarchy for complex financial information
3. **Efficient Scanning**: Users should quickly find key metrics and actions
4. **Accessibility**: High contrast, readable text for financial data

## Typography System

**Font Families**:
- Primary: Inter (via Google Fonts) - exceptional readability for numbers and data
- Monospace: JetBrains Mono - for currency amounts and numerical data

**Hierarchy**:
- Page Titles: text-3xl font-semibold (Dashboard, Transactions)
- Section Headers: text-xl font-semibold
- Card Titles: text-lg font-medium
- Body Text: text-base
- Labels/Meta: text-sm text-gray-600
- Financial Amounts: text-2xl font-semibold tracking-tight (for key metrics)
- Currency Values: font-mono for consistent digit alignment

## Layout System

**Spacing Units**: Use Tailwind units of **4, 6, 8, 12, 16** for consistent rhythm
- Component padding: p-6
- Card spacing: space-y-4
- Section margins: mb-8, mb-12
- Page padding: p-8

**Grid Structure**:
- Dashboard: 3-column grid for metric cards (grid-cols-1 md:grid-cols-3 gap-6)
- Transaction tables: Full-width with proper column spacing
- Forms: Single column, max-w-md for focused input

## Component Library

### Authentication Pages
- Centered card layout (max-w-md mx-auto)
- Logo at top, form below
- Clear "Login" / "Register" headings
- Input fields with labels above
- Primary action button (full width)
- Secondary link below for switching auth modes

### Dashboard Layout
**Header Bar**:
- User name and ownership % on left
- "Buy Shares" and "Apply for Loan" buttons on right
- Subtle bottom border separation

**Metric Cards** (3-column grid):
1. Total Invested (₱ amount, share count below)
2. Ownership Percentage (large %, total pool context)
3. Monthly Dividends (this month + total earned)

**Active Loan Section** (if exists):
- Card with loan details: principal, monthly payment, remaining months
- Progress bar showing repayment completion
- Next payment date prominently displayed

**Dividend History Table**:
- Columns: Month, Amount, Ownership %
- Striped rows for readability
- Monospace font for amounts

**Transaction Log**:
- Tabbed or filtered view (All, Shares, Loans, Repayments, Dividends)
- Table: Date, Type, Amount, Status
- Icons for transaction types

### Share Purchase Modal
- Centered modal overlay
- Share quantity selector (increments of 1)
- Live calculation showing: Shares × ₱500 = Total
- Capital pool impact preview
- Confirm button

### Loan Application Modal
- Available capital pool displayed prominently
- Loan amount input
- Auto-calculated display:
  - Total interest (2%)
  - Monthly payment breakdown
  - 5-month schedule preview table
- Clear eligibility check ("No active loan" requirement)
- Apply button

### Data Tables
- Header row with medium font-weight
- Alternating row backgrounds for readability
- Right-aligned currency columns
- Status badges (Active, Paid, Pending)
- Responsive: stack on mobile with card-style layout

### Financial Cards
- White background, subtle shadow
- Border or subtle outline
- Padding: p-6
- Clear label-value pairs
- Use of hierarchy (large numbers, smaller context)

## Navigation
- Top navigation bar with app logo/name
- Dashboard, Transactions, Profile links
- Logout button on right
- Mobile: hamburger menu

## Status Indicators
- **Active Loan**: Orange badge
- **Paid**: Green badge  
- **Dividend Earned**: Blue badge
- **Share Purchase**: Purple badge

## Responsive Behavior
- Desktop: 3-column metric cards, full tables
- Tablet (md): 2-column cards, scrollable tables
- Mobile: Single column stack, card-based transaction list

## Images
**No hero images** - This is a dashboard application. Focus on data visualization and clear information architecture. Use icons from **Heroicons** for:
- Navigation items
- Transaction type indicators
- Status icons
- Empty states (when no data exists)

## Special Considerations
- **Currency Formatting**: Always use ₱ symbol, thousand separators (₱1,234.56)
- **Empty States**: Friendly messages when no transactions/dividends exist
- **Loading States**: Skeleton screens for data-heavy sections
- **Error States**: Clear validation messages for forms
- **Confirmation Dialogs**: For critical actions (loan application, share purchase)

## Key Interactions
- Hover states on table rows (subtle background change)
- Button states: Clear hover, active, and disabled styles
- Modal overlays with backdrop blur
- Form validation: inline error messages below fields
- Success notifications: Toast-style at top of page

This design creates a trustworthy, efficient financial dashboard that prioritizes data clarity and user confidence in managing their investments and loans.