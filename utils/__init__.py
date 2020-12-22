import inspect

def import_recipe(file, class_name='Recipe'):
    '''
    Mechanism to load a recipe from other file in order to inherit from it
    @file The path where the .recipe file is
    @class_name The recipe to return, by default 'Recipe'
    '''
    upframe = inspect.stack()[1].frame
    new_globals = upframe.f_globals.copy()
    new_globals['__file__'] = file
    exec(open(file).read(), new_globals)
    recipe_class = new_globals[class_name]
    # Cerbero checks for the __module__ being 'builtins' in order to load it again
    recipe_class.__module__ = None
    return recipe_class
