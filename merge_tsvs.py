import click
import pandas as pd

@click.command()
@click.option('--file_existing', required=True, type=str, help="")
@click.option('--file_append', required=True, type=str, help="")
@click.option('--file_out', required=True, type=str, help="")
def do_this(file_existing: str, file_append: str, file_out: str):
    # load and prepare existing data
    df = pd.read_table(file_existing, sep="\t", names=["date", "temperature", "humidity"], encoding="utf-8")
    df = df.drop(df.loc[df['temperature']=="temperature"].index)
    df = df.dropna()
    df["date"] = df["date"].apply(lambda x: x.replace(u"\x07", "") if type(x)==str else x)
    df["date"] = pd.to_datetime(df["date"], format="%Y-%m-%dT%H:%M:%S")
    # print(df)
    # load and prepare data to append
    df_append = pd.read_table(file_append, sep="\t", names=["date", "temperature", "humidity"], encoding="utf-8")
    df_append = df_append.drop(df_append.loc[df_append['temperature']=="temperature"].index)
    df_append = df_append.dropna()
    df_append["date"] = df_append["date"].apply(lambda x: x.replace(u"\x07", "") if type(x)==str else x)
    df_append["date"] = pd.to_datetime(df_append["date"])
    # print(df)
    # merge existing and new data
    df_new = df.append(df_append)
    df_new = df_new.sort_values("date")
    df_new = df_new.drop_duplicates(keep=False)
    # print(df_new)
    df_new.to_csv(file_out, sep="\t", index=False)


if __name__ == '__main__':
    do_this()

