@doc """
    write_hdf5( hdf_out::String, S::GphysData[, KWs] )

Write data in a seismic HDF5 format to file `hdf_out` from structure `S`.

## Keywords
|KW           | Type      | Default   | Meaning                               |
|:---         |:---       |:---       |:---                                   |
| add         | Bool      | false     | Add new traces to file as needed?     |
| chans       | ChanSpec  | 1:S.n     | Channels to write to file             |
| len         | Period    | Day(1)    | Length of new traces added to file    |
| ovr         | Bool      | false     | Overwrite data in existing traces?    |
| v           | Int64     | 0         | verbosity                             |

## Write Methods
### Add (add = true)
This KW determines the start and end times of all data in `chans`, and
initializes new traces (filled with NaNs) of length = `len`.

#### ASDF behavior
Mode `add=true` follows these steps in this order:
1. Determine times of all data in `S[chans]` and all traces in "Waveforms/".
1. For all data in `S[chans]` that cannot be written to an existing trace, a new
trace of length = `len` sampled at `S.fs[i]` is initialized (filled with NaNs).
1. If a segment in `S[chans]` overlaps a trace in "Waveforms/" (including newly-
created traces):
  + Merge the header data in `S[chans]` into the relevant station XML.
  + Overwrite the relevant segment(s) of the trace.

Thus, unless `len` exactly matches the time boundaries of each segment in `S`,
the traces created will be intentionally larger.

### Overwrite (ovr = true)
If `ovr=true` is specified, but `add=false`, `write_hdf5` *only* overwrites
*existing* data in `hdf_out`.
* No new trace data objects are created in `hdf_out`.
* No new file is created. If `hdf_out` doesn't exist, nothing happens.
* If no traces in `hdf_out` overlap segments in `S`, `hdf_out` isn't modified.
* In ASDF format, station XML is merged in channels that are partly overwritten.

See also: read_hdf5
""" write_hdf5
function write_hdf5(file::String, S::GphysData;
  chans     ::Union{Integer, UnitRange, Array{Int64,1}} = Int64[], # channels
  add       ::Bool      = false,            # add traces
  fmt       ::String    = "asdf",           # data format
  len       ::Period    = Day(1),           # length of added traces
  ovr       ::Bool      = false,            # overwrite trace data
  v         ::Int64     = KW.v              # verbosity
  )

  chans = mkchans(chans, S.n)
  if fmt == "asdf"
    write_asdf(file, S, chans, add=add, len=len, ovr=ovr, v=v)
  else
    error("Unknown file format (possibly NYI)!")
  end

  return nothing
end

function write_hdf5(file::String, C::GphysChannel;
  add       ::Bool      = false,            # add traces
  fmt       ::String    = "asdf",           # data format
  len       ::Period    = Day(1),           # length of added traces
  ovr       ::Bool      = false,            # overwrite trace data
  v         ::Int64     = KW.v              # verbosity
  )

  S = SeisData(C)
  write_hdf5(file, S, fmt=fmt, ovr=ovr, v=v)
  return nothing
end