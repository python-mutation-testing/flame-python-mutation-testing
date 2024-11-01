pip install -e "."
pip install cryptography
pip install setuptools
coverage run -m pytest
coverage combine
