import json
from pathlib import Path

import click
from dateutil import parser


@click.command()
@click.argument('reports_dir', type=click.Path(file_okay=False, exists=True))
def main(reports_dir):
    """
    Creates a `reports/reports.json` file (replacing if exists) that contains the dates of all
    `*_Evaluation_flu_hosp.html` files under `reports/` , sorted descending by date.

    To run: Execute this program passing this repo's root as `reports_dir`.

    :param: reports_dir: the directory that contains `*_Evaluation_flu_hosp.html` files
    """
    reports_path = Path(reports_dir)
    dates = [path.name.split('_')[0] for path in reports_path.glob('*_Evaluation_flu_hosp.html')]
    with open(reports_path / 'reports.json', 'w') as json_fp:
        json.dump(sorted(dates, reverse=True, key=lambda _: parser.parse(_)), json_fp)


if __name__ == '__main__':
    main()
