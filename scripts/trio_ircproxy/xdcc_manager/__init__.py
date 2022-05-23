from re import compile
def parse_pack(packmsg: str) -> dict:
    # This is my first regex I have ever successfully wrote, I hope it works as well as I intended.
    linere = compile(
        r'(?P<pack>#\b[\d])+[\s]+\b(?P<count>[\d]+)[x][\s]+.?\b(?P<size>[\d]+r\'\.\'|[\d].+[BKMGTP]).\s\b(?P<file>.+)')
    packinfo = linere.match(packmsg)
    if not packinfo:
        return {}
    pack_num = packinfo.group('pack')
    dl_count = packinfo.group('count')
    size = packinfo.group('size')
    file = packinfo.group('file')
    return {'pack_num': pack_num, 'dl_count': dl_count, 'size': size, 'file': file}
