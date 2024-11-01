mv git_folder .git
pip install -e "."
pip install -e ".[tests]"
pip install setuptools
coverage run -m pytest
coverage combine
mv .git git_folder