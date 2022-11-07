import pandas as pd
from .... import dataframe as md

import pytest

def test_apply(setup):
    df = pd.DataFrame({'col': [1, 2, 3, 4]})
    a = md.DataFrame(df)
    b = a.apply(lambda x: 10 if x[0] else 20, output_type='dataframe', dtypes='int', axis=1).execute(
        extra_config={"check_all": False}
    )
    print(b)
