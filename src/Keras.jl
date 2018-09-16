module Keras

using PyCall
using Compat

import PyCall: PyObject

# We store our renamed aliases to aid with
# automatic docstring updating.
global const keras_func_aliases = Dict(
    "compile" => "compile!",
    "add" => "add!"
)

"""
Copied from LazyHelp in PyPlot.jl.

define a documentation object that lazily looks up
help from a PyObject via zero or more keys.
This saves us time when loading Keras, since we don't have
to load up all of the documentation strings right away.
"""
struct PyDoc
    obj::PyObject
    names::Tuple{Vararg{Symbol}}

    PyDoc(obj::PyObject, name::Symbol) = new(obj, (name,))
end

function Base.show(io::IO, ::MIME"text/plain", doc::PyDoc)
    obj = doc.obj

    for name in doc.names
        obj = obj[name]
    end

    if haskey(obj, "__doc__")
        print(io, convert(AbstractString, obj[:__doc__]))
    else
        print(io, "no Python docstring found for PyDoc($(doc.obj), $(doc.names))")
    end
end

Base.show(io::IO, doc::PyDoc) = show(io, "text/plain", doc)

function Base.Docs.catdoc(docs::PyDoc...)
    Base.Docs.Text() do io
        for doc in docs
            show(io, MIME"text/plain"(), doc)
        end
    end
end

# We need to handle our python dependencies carefully here
global const _keras = PyNULL()
global const _backend = PyNULL()
global const _layers = PyNULL()
global const _models = PyNULL()
global const _regularizers = PyNULL()
global const _optimizers = PyNULL()
global const _callbacks = PyNULL()
global const _constraints = PyNULL()
global const _initializers = PyNULL()

function __init__()
    copy!(_keras, pyimport("keras"))
    copy!(_backend, pyimport("keras.backend"))
    copy!(_layers, pyimport("keras.layers"))
    copy!(_models, pyimport("keras.models"))
    copy!(_regularizers, pyimport("keras.regularizers"))
    copy!(_optimizers, pyimport("keras.optimizers"))
    copy!(_callbacks, pyimport("keras.callbacks"))
    copy!(_constraints, pyimport("keras.constraints"))
    copy!(_initializers, pyimport("keras.initializers"))
end

include("tensors.jl")
include("utils.jl")
include("callbacks.jl")
include("constraints.jl")
include("initializers.jl")
include("optimizers.jl")
include("regularizers.jl")
include("layers.jl")
include("models.jl")

end
