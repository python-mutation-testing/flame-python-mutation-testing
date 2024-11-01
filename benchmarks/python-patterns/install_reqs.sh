pip install "."
pip install -r requirements-dev.txt
pip install setuptools
pip install pytest==8.2.0
coverage run -m pytest
coverage combine