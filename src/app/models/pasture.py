class Pasture:
    def __init__(self, id: int, area: float, number_of_animals: int, occupancy_dates: list, rest_dates: list):
        self.id = id
        self.area = area
        self.number_of_animals = number_of_animals
        self.occupancy_dates = occupancy_dates
        self.rest_dates = rest_dates

    def __repr__(self):
        return f"<Pasture(id={self.id}, area={self.area}, number_of_animals={self.number_of_animals})>"

    def is_available(self, date: str) -> bool:
        """Check if the pasture is available on a given date."""
        if date in self.occupancy_dates:
            return False
        return True

    def add_occupancy(self, date: str):
        """Add a date to the occupancy list."""
        if date not in self.occupancy_dates:
            self.occupancy_dates.append(date)

    def add_rest(self, date: str):
        """Add a date to the rest list."""
        if date not in self.rest_dates:
            self.rest_dates.append(date)