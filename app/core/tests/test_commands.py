from unittest.mock import patch, MagicMock
from django.core.management import call_command
from django.db.utils import OperationalError
from django.test import SimpleTestCase
from psycopg import OperationalError as PsycopgError  # psycopg3 compatible


@patch("django.db.utils.ConnectionHandler.__getitem__")
class CommandTests(SimpleTestCase):
    """Test commands for waiting on database"""

    def test_wait_for_db_ready(self, patched_getitem):
        """Test waiting for database when database is available"""
        mock_conn = MagicMock()
        patched_getitem.return_value = mock_conn

        call_command("wait_for_db")

        mock_conn.cursor.assert_called_once()
        patched_getitem.assert_called_once()

    @patch("time.sleep", return_value=True)
    def test_wait_for_db_delay(self, patched_sleep, patched_getitem):
        """Test waiting for database when getting OperationalError"""
        mock_conn = MagicMock()
        # Raise errors 5 times, succeed on 6th
        patched_getitem.side_effect = [PsycopgError] * 2 + [OperationalError] * 3 + [mock_conn]

        call_command("wait_for_db")

        self.assertEqual(patched_getitem.call_count, 6)
        mock_conn.cursor.assert_called_once()
