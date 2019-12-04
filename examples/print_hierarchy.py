#!/usr/bin/env python3

import sys
import os

# Ignore this. Only needed for this example
this_dir = os.path.dirname(os.path.realpath(__file__))
sys.path.insert(0, os.path.join(this_dir, "../"))

from systemrdl import RDLCompiler, RDLListener, RDLWalker, RDLCompileError
from systemrdl.node import FieldNode
from systemrdl import rdltypes

# parameters
PRINT_STRUCTS: bool = True
PRINT_DEFINES: bool = False
PRINT_ENUMS:   bool = False

# Collect input files from the command line arguments
input_files = sys.argv[1:]


# Create an instance of the compiler
rdlc = RDLCompiler()


try:
    # Compile all the files provided
    for input_file in input_files:
        rdlc.compile_file(input_file)

    # Elaborate the design
    root = rdlc.elaborate()
except RDLCompileError:
    # A compilation error occurred. Exit with error code
    sys.exit(1)


# Define a listener that will print out the register model hierarchy
class MyModelPrintingListener(RDLListener):
    def __init__(self):
        self.indent = 0

    def enter_Component(self, node):
        # n2 = node.descendants(unroll=True)
        # for child in n2:
        #     print("in enter_Component: printing child", child.get_path_segment(), child.get_path(), child.list_properties() )


        if not isinstance(node, FieldNode):
            bit_range_str = ""
            #bit_range_str = "[array_dimensions:%s size:%s total_size:%s ]" % (node.array_dimensions, node.size, node.total_size)
            #bit_range_str = "[%d:%d]" % (node.high, node.low)
            #sw_access_str = "sw=%s" % node.get_property("sw").name
            #print("\t"*self.indent, bit_range_str, node.get_path_segment(), sw_access_str)
            # print("\t"*self.indent, bit_range_str, node.get_path_segment())
            #
            # print("\t"*self.indent, node.get_path_segment())
            self.indent += 1

    def enter_Reg(self, node):
        #print("i'm in reg")
        #print("\t"*self.indent, node.get_path_segment(), node.descendants, node.get_property('regwidth'))
        n2 = node.descendants(unroll=True)
        #print(len(n2)) # can't do this as n2 is a generator

        print("typedef struct packed {") if (PRINT_STRUCTS & self.is_not_enum(node)) else None
        if PRINT_ENUMS:
            for child in n2:
                #print("printing child", child.get_path_segment(), child.get_path(), child.width, child.list_properties(), child.lsb )
                # to get the default value of a field, use the child.get_property("reset")

                # #if not rdltypes.is_user_enum(child.get_property("encode")):
                #     print("\t logic [%d:%d]" % node.high, node.low, child.get_path_segment(), ";"  )
                # print("I'm an enum ",
                # child.get_property("encode"),
                # rdltypes.is_user_enum(child.get_property("encode")),
                # #child.get_property("encode").get_default(),
                # #rdltypes.UserEnum(child.get_property("encode")),
                # child.get_property("encode")
                # ) if "encode" in child.list_properties() else None

                #---------------
                # print ENUM

                if child.get_property("encode"):
                    print("typedef enum logic [%d:0] { // %s" % (child.width-1, child.get_property('desc')))
                    for vals in (child.get_property("encode")):
                        #print("desc: ", vals.rdl_desc)
                        print("\t"*self.indent, vals.name, "=", vals.value, "; // ", vals.rdl_desc)
                    print("} %s;\n" % child.get_property("encode").__name__)

                    # print defines for enums now
                    for vals in (child.get_property("encode")):
                        print(
                              "`define ",
                              "%s_%s" % (child.get_property("encode").__name__.upper(), vals.name.upper()),
                              vals.value,
                              )
                    print("\n\n")

    def is_not_enum(self, node):
        return ~(node.get_property('shared') ) # | node.get_property('woclr')

    def enter_Field(self, node):
        # Print some stuff about the field
        bit_range_str = "[%d:%d] width:%d" % (node.high, node.low, node.width)
        #         bit_range_str = "[%d:%d] width:%d, value:%s" % (node.high, node.low, node.width, node.value)
        
        sw_access_str = "sw=%s" % node.get_property("sw").name
        #print("\t"*self.indent, bit_range_str, node.get_path(), node.list_properties(), sw_access_str)
        #print("\t"*self.indent, node.list_properties(), node.width)
        if PRINT_STRUCTS:
            #print(node.list_properties())
            if node.get_property('encode') :
                # we're managing an enum here:
                print("\t", node.get_property('encode').__name__, node.get_path_segment(), ";")
            else:
                print("\t logic [%d:%d]" % (node.high, node.low), node.get_path_segment(), ";"  )


        if PRINT_DEFINES:
            print("\t"*self.indent, "`define", node.get_path().upper().replace('.','_') + "_WIDTH_IN_BITS", node.width)
            # bit postiion TODO: if node.high == node.low, then only print one value
            print("\t"*self.indent, "`define", node.get_path().upper().replace('.','_') + "_BIT_POSITION","[%d:%d]" % (node.high, node.low))

    def exit_Reg(self,node):
        if PRINT_STRUCTS & self.is_not_enum(node):
            print(" } %s_t;" % (node.get_path().replace('.','_')))

    def exit_Component(self, node):
        if not isinstance(node, FieldNode):
            self.indent -= 1


# Traverse the register model!
walker = RDLWalker(unroll=True, skip_not_present=False)
listener = MyModelPrintingListener()
walker.walk(root, listener)
# try:
#     print("print root.list_properties()", root.list_properties())
#     amap = root.find_by_path("foo_map")
#     print("print amap.list_properties()", amap.list_properties())
#     for child in amap.list_properties():
#         prop = amap.get_property(child)
#         print(prop)  # <struct 'inner_struct' (abool, astring) at 0x111250390>
#         print(prop._members)  # OrderedDict([('abool', <class 'bool'>), ('astring', <class 'str'>)])
#
# finally:
#     pass
