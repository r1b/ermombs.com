# mattgliva.com

Portfolio website. See the [specification](SPEC.md) for more details. At a high
level, the site should be fast & simple.

## Usage

Set the following environment variables:

| Name                | Description                                     |
|---------------------|-------------------------------------------------|
| `GLIVA_GROUP`       | The system group the server drops privileges to |
| `GLIVA_HOST`        | The hostname the server binds to                |
| `GLIVA_PASSWORD`    | The web administration password                 |
| `GLIVA_PORT`        | The port the server binds to                    |
| `GLIVA_STATIC_ROOT` | The path to a folder containing static files    |
| `GLIVA_USER`        | The system user the server drops privileges to  |
| `GLIVA_USERNAME`    | The web administration username                 |

## Known Issues

* `read-multipart-form-data` is slow on large files. I have contacted the author
   to explore potential solutions.
