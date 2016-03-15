type FreeListEntry
  array::AFArray
  isResult::Bool
end

FreeListEntry(arr) = FreeListEntry(arr, false)

type FreeList
  list::Vector{Vector{FreeListEntry}}
end

FreeList() = FreeList(Vector{Vector{FreeListEntry}}())

current(fl::FreeList) =
  length(fl.list) > 0 ?
  Nullable{Vector{FreeListEntry}}(last(fl.list)) :
  Nullable{Vector{FreeListEntry}}()

newScope!(fl::FreeList) = push!(fl.list, Vector{FreeListEntry}())

function register!(fl::FreeList, arr::AFArray)
  curr = current(fl)
  if !isnull(curr)
    curr = get(curr)
    push!(curr, FreeListEntry(arr))
  end
end

raiseNoScope() = error("There is no active scope.")

function markResult!(fl::FreeList, arr::AFArray)
  curr = current(fl)
  if !isnull(curr)
    curr = get(curr)
    idx = findfirst(x -> x.array == arr, curr)
    idx == 0 && error("Array isn't registered in the current scope.")
    curr[idx].isResult = true
    arr
  else
    raiseNoScope()
  end
end

function endScope!(fl::FreeList)
  curr = current(fl)
  if !isnull(curr)
    curr = get(curr)
    for entry in filter(x -> !x.isResult, curr)
      release!(entry.array)
    end
    pop!(fl.list)
  else
    raiseNoScope()
  end
end
