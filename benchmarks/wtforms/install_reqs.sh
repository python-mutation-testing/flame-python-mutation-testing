pip install -e "."
pip install pytest
pip install babel
pip install email_validator
pip install setuptools
coverage run -m pytest
coverage combine
