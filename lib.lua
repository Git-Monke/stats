require ".luam"

use("tableutils")

-- Warning: WILL sort your table.
local function median(dataset)
    table.sort(dataset)

    local mid = math.floor(#dataset / 2 + 0.5)

    if #dataset % 2 == 0 then
        return (dataset[mid] + dataset[mid + 1]) / 2, mid
    else
        return dataset[mid], mid
    end
end

-- Warning: WILL sort your table.
local function quartiles(dataset)
    if #dataset == 0 then
        return nil, nil, nil
    end

    if #dataset == 1 then
        return dataset[1], dataset[1], dataset[1]
    end

    local _median, midpoint = median(dataset)

    local adjust = #dataset % 2 == 0 and 0 or -1
    local Q1_mid = math.floor((midpoint + adjust) / 2 + 0.5)
    local Q3_mid = midpoint + Q1_mid

    if (midpoint + adjust) % 2 == 0 then
        Q1 = (dataset[Q1_mid] + dataset[Q1_mid + 1]) / 2
        Q3 = (dataset[Q3_mid] + dataset[Q3_mid + 1]) / 2
    else
        Q1 = dataset[Q1_mid]
        Q3 = dataset[Q3_mid]
    end

    return Q1, _median, Q3
end

local function sum(dataset)
    return table.sum(dataset)
end

-- {1, 2, 3, 4, 5, 6, 7, 8, 9}
local function IQR(dataset)
    if #dataset % 2 == 0 then

    else
        local step = math.ceil(#dataset / 4)
        return dataset[#dataset - step] - dataset[step]
    end
end

local function max(dataset)
    return table.ireduce(dataset, function(a, c) return math.max(a, c) end, math.mininteger)
end

local function min(dataset)
    return table.ireduce(dataset, function(a, c) return math.min(a, c) end, math.huge)
end

-- Smallest 32 bit integer
local reallySmallInt = -0x80000000

local function extrema(dataset)
    local minmax = table.ireduce(dataset, function(a, c)
        if a[1] > c then
            a[1] = c
        elseif a[2] < c then
            a[2] = c
        end
        return a
    end, { math.huge, reallySmallInt }) -- Min, Max
    return minmax[1], minmax[2]
end

local function mean(dataset)
    return table.sum(dataset) / #dataset
end

local function mode(dataset)
    return table.ireduce(dataset, -- converts dataset to key|value pairs where the value is how many times that key appeared in the dataset
        function(a, v)
            a[v] = a[v] and a[v] + 1 or 1
            return a
        end, T {}):reduce(function(a, v, k)
        if v > a[1] then
            a[1] = v
            a[2] = k
        end
        return a
    end, T { 0, 0 })[2] -- t[1] = running maximum, t[2] = key associated with that maximum
end

local function variance(dataset, _mean)
    _mean = _mean or mean(dataset)
    return dataset:imap(function(v) return v * v - 2 * _mean * v + _mean * _mean end):sum() / #dataset
end

local function stdDev(dataset, _variance)
    _variance = _variance or variance(dataset)
    return math.sqrt(_variance)
end

local function stdErr(dataset, _stdDev)
    _stdDev = _stdDev or stdDev(dataset)
    return _stdDev / math.sqrt(#dataset)
end

local function summarize(dataset)
    T(dataset) -- Makes the code cleaner

    local sum = dataset:sum()
    local mean = sum / #dataset

    -- (v - mean)(v - mean) = v^2 - 2(mean)(v) + mean^2
    local variance = dataset:imap(function(v) return v * v - 2 * mean * v + mean * mean end):sum() / #dataset
    local stdDev = math.sqrt(variance)

    local stdErr = stdDev / math.sqrt(#dataset)

    local Q1, Q2, Q3 = quartiles(dataset)
    local min, max = extrema(dataset)
    local range = max - min

    local mode = mode(dataset)

    return {
        sum = sum,
        mean = mean,
        variance = variance,
        stdDev = stdDev,
        stdErr = stdErr,
        Q1 = Q1,
        Q2 = Q2,
        Q3 = Q3,
        median = Q2,
        min = min,
        max = max,
        range = range,
        mode = mode
    }
end

return {
    sum = sum,
    mean = mean,
    variance = variance,
    stdDev = stdDev,
    stdErr = stdErr,
    quartiles = quartiles,
    median = median,
    extrema = extrema,
    mode = mode,
    summarize = summarize
}
