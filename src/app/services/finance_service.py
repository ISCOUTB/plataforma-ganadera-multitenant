from datetime import datetime
from typing import List, Dict, Any

class FinanceService:
    def __init__(self, cost_repository, income_repository):
        self.cost_repository = cost_repository
        self.income_repository = income_repository

    def record_income(self, amount: float, category: str, date: datetime) -> Dict[str, Any]:
        if amount <= 0:
            raise ValueError("El monto debe ser mayor que cero.")
        
        income_data = {
            "amount": amount,
            "category": category,
            "date": date
        }
        return self.income_repository.save(income_data)

    def record_expense(self, amount: float, category: str, date: datetime) -> Dict[str, Any]:
        if amount <= 0:
            raise ValueError("El monto debe ser mayor que cero.")
        
        expense_data = {
            "amount": amount,
            "category": category,
            "date": date
        }
        return self.cost_repository.save(expense_data)

    def get_financial_report(self, start_date: datetime, end_date: datetime) -> Dict[str, Any]:
        incomes = self.income_repository.get_incomes(start_date, end_date)
        expenses = self.cost_repository.get_expenses(start_date, end_date)

        total_income = sum(income['amount'] for income in incomes)
        total_expense = sum(expense['amount'] for expense in expenses)
        balance = total_income - total_expense

        report = {
            "total_income": total_income,
            "total_expense": total_expense,
            "balance": balance,
            "incomes": incomes,
            "expenses": expenses
        }
        return report

    def get_income_categories(self) -> List[str]:
        return self.income_repository.get_categories()

    def get_expense_categories(self) -> List[str]:
        return self.cost_repository.get_categories()