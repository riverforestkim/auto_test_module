

class ImportTestModule() :
    def test_method(self):
        return "TEST_STRING"

    def test_method_arg(self, nNum):
        return nNum

    def python2_ipaddress_test(self) :
        bFlag = True

        try :
            import ipaddress
        except Exception :
            bFlag = False

        return bFlag
