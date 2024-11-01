from praw.models import PollOption

from ... import UnitTest


class TestPollOption(UnitTest):
    def test_repr(self, reddit):
        option = PollOption(reddit, {"id": "anID", "text": "theText", "vote_count": 0})
        assert repr(option) == "PollOption(id='anID')"

    def test_str(self, reddit):
        option = PollOption(reddit, {"id": "anID", "text": "theText", "vote_count": 0})
        assert str(option) == "theText"
