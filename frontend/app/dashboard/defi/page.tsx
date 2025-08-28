"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts"
import { TrendingUp, Shield, Clock, ExternalLink, Plus, Minus, Gift } from "lucide-react"

// Sample DeFi positions data
const defiPositions = [
  {
    protocol: "ALEX",
    type: "Liquidity Pool",
    pair: "STX/USDA",
    value: "$8,450",
    apy: "12.5%",
    risk: "medium",
    staked: "5,000 STX",
    rewards: "125.5 ALEX",
    lockPeriod: "None",
    yieldHistory: [
      { date: "Week 1", yield: 11.2 },
      { date: "Week 2", yield: 12.8 },
      { date: "Week 3", yield: 13.1 },
      { date: "Week 4", yield: 12.5 },
    ],
  },
  {
    protocol: "Stacking DAO",
    type: "Stacking",
    pair: "STX",
    value: "$18,750",
    apy: "8.2%",
    risk: "low",
    staked: "15,000 STX",
    rewards: "45.2 STX",
    lockPeriod: "2 cycles",
    yieldHistory: [
      { date: "Week 1", yield: 8.1 },
      { date: "Week 2", yield: 8.3 },
      { date: "Week 3", yield: 8.0 },
      { date: "Week 4", yield: 8.2 },
    ],
  },
  {
    protocol: "Arkadiko",
    type: "Vault",
    pair: "STX/USDA",
    value: "$3,200",
    apy: "6.1%",
    risk: "low",
    staked: "2,500 STX",
    rewards: "8.7 DIKO",
    lockPeriod: "None",
    yieldHistory: [
      { date: "Week 1", yield: 6.5 },
      { date: "Week 2", yield: 6.0 },
      { date: "Week 3", yield: 5.8 },
      { date: "Week 4", yield: 6.1 },
    ],
  },
]

// Available farming opportunities
const farmingOpportunities = [
  {
    protocol: "Velar",
    pair: "STX/sBTC",
    apy: "15.8%",
    tvl: "$2.1M",
    risk: "high",
    description: "New high-yield pool with sBTC rewards",
  },
  {
    protocol: "ALEX",
    pair: "ALEX/STX",
    apy: "18.2%",
    tvl: "$850K",
    risk: "high",
    description: "Native token farming with bonus rewards",
  },
  {
    protocol: "Bitflow",
    pair: "STX/USDA",
    apy: "9.5%",
    tvl: "$5.2M",
    risk: "medium",
    description: "Stable yield with established liquidity",
  },
]

// APY comparison data
const apyComparison = [
  { protocol: "ALEX", apy: 12.5, risk: "medium", tvl: "$45M" },
  { protocol: "Velar", apy: 15.8, risk: "high", tvl: "$12M" },
  { protocol: "Stacking DAO", apy: 8.2, risk: "low", tvl: "$180M" },
  { protocol: "Arkadiko", apy: 6.1, risk: "low", tvl: "$25M" },
  { protocol: "Bitflow", apy: 9.5, risk: "medium", tvl: "$35M" },
]

export default function DeFiPositionsPage() {
  const [selectedPosition, setSelectedPosition] = useState(0)

  const getRiskColor = (risk: string) => {
    switch (risk) {
      case "low":
        return "text-success"
      case "medium":
        return "text-primary"
      case "high":
        return "text-destructive"
      default:
        return "text-muted-foreground"
    }
  }

  const getRiskBadge = (risk: string) => {
    switch (risk) {
      case "low":
        return (
          <Badge variant="secondary" className="bg-success/10 text-success border-success/20">
            Low Risk
          </Badge>
        )
      case "medium":
        return (
          <Badge variant="secondary" className="bg-primary/10 text-primary border-primary/20">
            Medium Risk
          </Badge>
        )
      case "high":
        return (
          <Badge variant="secondary" className="bg-destructive/10 text-destructive border-destructive/20">
            High Risk
          </Badge>
        )
      default:
        return <Badge variant="outline">Unknown</Badge>
    }
  }

  const totalValue = defiPositions.reduce(
    (sum, pos) => sum + Number.parseFloat(pos.value.replace("$", "").replace(",", "")),
    0,
  )

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-foreground mb-2">DeFi Positions</h1>
        <p className="text-muted-foreground">
          Manage your positions across ALEX, Arkadiko, Velar, and Stacking protocols.
        </p>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Total DeFi Value</p>
                <p className="text-2xl font-bold text-foreground font-mono">${totalValue.toLocaleString()}</p>
              </div>
              <TrendingUp className="w-8 h-8 text-success" />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Active Positions</p>
                <p className="text-2xl font-bold text-foreground">{defiPositions.length}</p>
              </div>
              <Shield className="w-8 h-8 text-primary" />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Avg APY</p>
                <p className="text-2xl font-bold text-foreground">9.3%</p>
              </div>
              <TrendingUp className="w-8 h-8 text-success" />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Pending Rewards</p>
                <p className="text-2xl font-bold text-foreground">$342</p>
              </div>
              <Gift className="w-8 h-8 text-primary" />
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Active Positions */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="space-y-4">
          <h2 className="text-xl font-semibold text-foreground">Your Positions</h2>
          {defiPositions.map((position, index) => (
            <Card
              key={index}
              className={`cursor-pointer transition-all ${selectedPosition === index ? "ring-2 ring-primary" : ""}`}
              onClick={() => setSelectedPosition(index)}
            >
              <CardContent className="p-6">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center">
                      <span className="text-sm font-bold text-primary">
                        {position.protocol.slice(0, 2).toUpperCase()}
                      </span>
                    </div>
                    <div>
                      <h3 className="font-semibold text-foreground">{position.protocol}</h3>
                      <p className="text-sm text-muted-foreground">
                        {position.type} • {position.pair}
                      </p>
                    </div>
                  </div>
                  {getRiskBadge(position.risk)}
                </div>

                <div className="grid grid-cols-2 gap-4 mb-4">
                  <div>
                    <p className="text-sm text-muted-foreground">Position Value</p>
                    <p className="text-lg font-bold text-foreground">{position.value}</p>
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground">APY</p>
                    <p className="text-lg font-bold text-success">{position.apy}</p>
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground">Staked</p>
                    <p className="text-sm font-medium text-foreground">{position.staked}</p>
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground">Rewards</p>
                    <p className="text-sm font-medium text-foreground">{position.rewards}</p>
                  </div>
                </div>

                <div className="flex gap-2">
                  <Button size="sm" className="flex-1">
                    <Gift className="w-4 h-4 mr-2" />
                    Claim
                  </Button>
                  <Button size="sm" variant="outline" className="flex-1 bg-transparent">
                    <Plus className="w-4 h-4 mr-2" />
                    Stake More
                  </Button>
                  <Button size="sm" variant="outline" className="flex-1 bg-transparent">
                    <Minus className="w-4 h-4 mr-2" />
                    Unstake
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>

        {/* Position Details & Yield History */}
        <div className="space-y-4">
          <h2 className="text-xl font-semibold text-foreground">Position Details</h2>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                {defiPositions[selectedPosition].protocol} Yield History
                <ExternalLink className="w-4 h-4 text-muted-foreground" />
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="h-64 mb-4">
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={defiPositions[selectedPosition].yieldHistory}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                    <XAxis dataKey="date" stroke="#64748b" fontSize={12} />
                    <YAxis stroke="#64748b" fontSize={12} />
                    <Tooltip
                      formatter={(value: number) => [`${value}%`, "APY"]}
                      labelStyle={{ color: "#242c34" }}
                      contentStyle={{ backgroundColor: "#ffffff", border: "1px solid #e2e8f0" }}
                    />
                    <Line
                      type="monotone"
                      dataKey="yield"
                      stroke="#4caf50"
                      strokeWidth={2}
                      dot={{ fill: "#4caf50", strokeWidth: 2, r: 4 }}
                    />
                  </LineChart>
                </ResponsiveContainer>
              </div>

              <div className="space-y-3">
                <div className="flex justify-between">
                  <span className="text-sm text-muted-foreground">Lock Period</span>
                  <span className="text-sm font-medium text-foreground">
                    {defiPositions[selectedPosition].lockPeriod}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-muted-foreground">Risk Level</span>
                  <span className={`text-sm font-medium ${getRiskColor(defiPositions[selectedPosition].risk)}`}>
                    {defiPositions[selectedPosition].risk.charAt(0).toUpperCase() +
                      defiPositions[selectedPosition].risk.slice(1)}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-muted-foreground">Next Reward</span>
                  <span className="text-sm font-medium text-foreground">
                    <Clock className="w-3 h-3 inline mr-1" />2 days
                  </span>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>

      {/* APY Comparison Table */}
      <Card>
        <CardHeader>
          <CardTitle>Protocol APY Comparison</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Protocol</TableHead>
                <TableHead>APY</TableHead>
                <TableHead>Risk</TableHead>
                <TableHead>TVL</TableHead>
                <TableHead>Action</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {apyComparison.map((protocol, index) => (
                <TableRow key={index}>
                  <TableCell className="font-medium">{protocol.protocol}</TableCell>
                  <TableCell className="text-success font-medium">{protocol.apy}%</TableCell>
                  <TableCell>{getRiskBadge(protocol.risk)}</TableCell>
                  <TableCell className="font-mono">{protocol.tvl}</TableCell>
                  <TableCell>
                    <Button size="sm" variant="outline">
                      View Details
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* Farming Opportunities */}
      <Card>
        <CardHeader>
          <CardTitle>New Farming Opportunities</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {farmingOpportunities.map((opportunity, index) => (
              <Card key={index} className="border-dashed border-2 hover:border-primary transition-colors">
                <CardContent className="p-4">
                  <div className="flex items-start justify-between mb-3">
                    <div>
                      <h4 className="font-semibold text-foreground">{opportunity.protocol}</h4>
                      <p className="text-sm text-muted-foreground">{opportunity.pair}</p>
                    </div>
                    {getRiskBadge(opportunity.risk)}
                  </div>

                  <div className="space-y-2 mb-4">
                    <div className="flex justify-between">
                      <span className="text-sm text-muted-foreground">APY</span>
                      <span className="text-sm font-bold text-success">{opportunity.apy}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-sm text-muted-foreground">TVL</span>
                      <span className="text-sm font-medium text-foreground">{opportunity.tvl}</span>
                    </div>
                  </div>

                  <p className="text-xs text-muted-foreground mb-3">{opportunity.description}</p>

                  <Button size="sm" className="w-full">
                    <Plus className="w-4 h-4 mr-2" />
                    Start Farming
                  </Button>
                </CardContent>
              </Card>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
