<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>API Documentation - Peminjaman Barang</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/redoc@2.1.3/bundles/redoc.standalone.css">
    <style>
        body {
            margin: 0;
            padding: 0;
        }
    </style>
</head>
<body>
    <redoc 
        spec-url="{{ url('/api/api-docs.json') }}"
        options='{
            "theme": {
                "colors": {
                    "primary": {
                        "main": "#6366f1"
                    }
                }
            },
            "scrollYOffset": 0,
            "hideDownloadButton": false,
            "disableSearch": false,
            "expandResponses": "200,201",
            "requiredPropsFirst": true,
            "sortOperationsAlphabetically": false,
            "sortTagsAlphabetically": false,
            "jsonSampleExpandLevel": 2,
            "hideSingleRequestSampleTime": false,
            "menuToggle": true,
            "nativeScrollbars": false,
            "pathInMiddlePanel": false,
            "hideHostname": false,
            "payloadSampleIdx": 0
        }'
    ></redoc>
    <script src="https://cdn.jsdelivr.net/npm/redoc@2.1.3/bundles/redoc.standalone.js"></script>
</body>
</html>

