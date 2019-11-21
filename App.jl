using DataFrames
using Distributions
using GLM
using Random
using StatsBase
using StatsPlots

pyplot()

# Generate some funky heteroscedastic data
data = DataFrame(y =[rand(TruncatedNormal(1, .4n, n/2, 2n)) for n in 1:100], x=collect(1:100))

# Model the data
ols = lm(@formula(y ~ x), data)

# Get cutoff points to group data (we’ll use these to generate the distributions)
groups = vcat(0, [percentile(data.x, n) for n in 10:20:100])
groups = [percentile(data.x, n) for n in 0:20:100]

dists = [
    fit(Normal, [data.y[i] for i in 1:length(data.y) if groups[j - 1] < data.x[i] < groups[j]])
    for j in 2:length(groups)
]

# The distributions are at the 20th, 40th, 60th, 80th, and 100th percentiles so this
# next variable will store values at the 10th, 30th, etc., percentiles so that dists
# appear in the middle of the data points that they represent when plotted

distlocs = [percentile(data.x, n) for n in 10:20:100]

xmin = minimum(data.y)
xmax = maximum(data.y)
xrange = collect(xmin:1:xmax)

# Add scatter points
p = plot(
    data.x,
    data.y,
    seriestype = :scatter,
    markersize = 2,
    markerstrokewidth = 0,
    markeralpha = 0.8
)

# Add regression line
plot!(data.x, predict(ols), line=:line, linestyle=:dash, linealpha=0.6)

# Add rest of distributions (30th - 90th)
for i in 1:length(dists)
    plot!(
        zeros(length(xrange)) .+ distlocs[i],
        xrange,
        [pdf(dists[i], x) for x in xrange],
        legend = false,
        fill=(0.0)
    )
end
