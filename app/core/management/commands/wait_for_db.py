from django.core.management.base import BaseCommand
from django.db import connections
from django.db.utils import OperationalError
import time

class Command(BaseCommand):
    """Django command to wait for the database to be available."""

    def handle(self, *args, **options):
        self.stdout.write('Waiting for database...')
        db_conn = connections['default']
        while True:
            try:
                db_conn.cursor()
                self.stdout.write(self.style.SUCCESS('Database available!'))
                break
            except OperationalError:
                self.stdout.write('Database unavailable, waiting 1 second...')
                time.sleep(1)
