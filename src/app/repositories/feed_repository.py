from sqlalchemy.orm import Session
from src.app.models.feed import Feed
from src.app.schemas.feed import FeedCreate, FeedUpdate

class FeedRepository:
    def __init__(self, db: Session):
        self.db = db

    def create_feed(self, feed: FeedCreate) -> Feed:
        db_feed = Feed(**feed.dict())
        self.db.add(db_feed)
        self.db.commit()
        self.db.refresh(db_feed)
        return db_feed

    def get_feed(self, feed_id: int) -> Feed:
        return self.db.query(Feed).filter(Feed.id == feed_id).first()

    def update_feed(self, feed_id: int, feed: FeedUpdate) -> Feed:
        db_feed = self.get_feed(feed_id)
        if db_feed:
            for key, value in feed.dict(exclude_unset=True).items():
                setattr(db_feed, key, value)
            self.db.commit()
            self.db.refresh(db_feed)
        return db_feed

    def delete_feed(self, feed_id: int) -> bool:
        db_feed = self.get_feed(feed_id)
        if db_feed:
            self.db.delete(db_feed)
            self.db.commit()
            return True
        return False

    def get_all_feeds(self) -> list[Feed]:
        return self.db.query(Feed).all()