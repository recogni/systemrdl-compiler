
class ComponentDef:
    # field, reg, regfile, addrmap, signal, mem
    
    def __init__(self):
        # Type name
        self.name = None
        
        # Instances of this component def
        self.instances = []
        
        # If the component got parameterized or modified, a copy of the def is
        # made.
        # This stores a link to the original def that the component was derived
        # If None, then this is the primary def
        self.derived_from_def = None
        
        # Child elements instantiated inside this component
        self.children = []
    
    def create_derived_def(self):
        """
        Returns a copy of the component definition so that a derivative variant
        can be created.
        This can be due to either non-default parameterization, or dynamic
        property assignment.
        """
        
        if(self.derived_from_def is not None):
            # Creating a derived def is only necessary when copying the primary
            # one. Doing yet another copy is unnecessary since it is already
            # unique.
            return(self)
        
        # Deepcopy self
        # - all properties, and their expressions
        # - all parameters
        # - all children
        #++ TODO
        
        # Link new copy to original
        # XXX.derived_from_def = self
        
        pass
        # return(XXX)


#-------------------------------------------------------------------------------
class Field(ComponentDef):
    pass

class Reg(ComponentDef):
    pass
    
class Regfile(ComponentDef):
    pass
    
class Addrmap(ComponentDef):
    pass
    
class Signal(ComponentDef):
    pass
    
class Mem(ComponentDef):
    pass

#===============================================================================
# Instances
#===============================================================================

class Inst:
    def __init__(self, typ:ComponentDef):
        
        # Component type definition that this instantiates
        self.typ = typ
        
        # Instance name
        self.name = None
        
        # Reference to the parent component of this instance
        self.parent = None
        

class AddressableInst(Inst):
    """
    Instance wrapper for addressable components:
        reg, regfile, addrmap, mem
    """
    def __init__(self, typ:ComponentDef):
        super().__init__(typ)
        
        # Relative address offset from the parent component
        self.addr_offset = None
        
        #------------------------------
        # Array Properties
        #------------------------------
        # If true, then array_size and array_stride are valid
        self.is_array = False
        
        # List of sizes for each array dimension.
        # Last item in list iterates the most frequently
        self.array_size = None
        
        # Address offset between array elements
        self.array_stride = None


class VectorInst(Inst):
    """
    Instance wrapper for vector-like components:
        field, signal
    """
    def __init__(self, typ:ComponentDef):
        super().__init__(typ)
        # TODO Add bitfield info here?