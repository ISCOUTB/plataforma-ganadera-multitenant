from datetime import datetime
from typing import List, Optional

class ReproductionEvent:
    def __init__(self, animal_id: str, event_type: str, date: datetime, result: Optional[str] = None):
        self.animal_id = animal_id
        self.event_type = event_type
        self.date = date
        self.result = result

class ReproductionService:
    def __init__(self):
        self.events: List[ReproductionEvent] = []

    def register_event(self, animal_id: str, event_type: str, date: datetime, result: Optional[str] = None) -> ReproductionEvent:
        event = ReproductionEvent(animal_id, event_type, date, result)
        self.events.append(event)
        return event

    def get_events_by_animal(self, animal_id: str) -> List[ReproductionEvent]:
        return [event for event in self.events if event.animal_id == animal_id]

    def get_all_events(self) -> List[ReproductionEvent]:
        return self.events

    def update_event(self, animal_id: str, event_type: str, date: datetime, result: Optional[str]) -> bool:
        for event in self.events:
            if event.animal_id == animal_id and event.event_type == event_type and event.date == date:
                event.result = result
                return True
        return False

    def delete_event(self, animal_id: str, event_type: str, date: datetime) -> bool:
        for event in self.events:
            if event.animal_id == animal_id and event.event_type == event_type and event.date == date:
                self.events.remove(event)
                return True
        return False