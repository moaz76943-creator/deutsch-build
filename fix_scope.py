with open("lib/services/pack_downloader_service.dart", "r") as f:
    content = f.read()

content = content.replace(
"""        String? currentETag = response.headers['etag'];
        String? previousETag = _eTags[languageCode];""",
"""        String? currentETag = response.headers['etag'];"""
)

with open("lib/services/pack_downloader_service.dart", "w") as f:
    f.write(content)
