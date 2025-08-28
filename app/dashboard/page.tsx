"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  PieChart,
  Pie,
  Cell,
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts"
import { TrendingUp, Clock, CheckCircle, AlertCircle, ExternalLink } from "lucide-react"

// Sample data from requirements
const portfolioData = {
  total_usd: "$87,543.21",
  change_24h: "+5.8%",
  assets: {
    STX: { balance: "25,000", usd_value: "$31,250", staked: "15,000" },
    BTC: { balance: "0.89", usd_value: "$41,230" },
    sBTC: { balance: "0.23", usd_value: "$10,063" },
  },
}

const defiPositions = [
  { protocol: "ALEX", type: "LP", value: "$8,450", apy: "12.5%" },
  { protocol: "Stacking DAO", type: "Staking", value: "$18,750", apy: "8.2%" },
  { protocol: "Arkadiko", type: "Vault", value: "$3,200", apy: "6.1%" },
]

// Chart data
const assetAllocation = [
  { name: "BTC", value: 41230, color: "#f7931a" },
  { name: "STX", value: 31250, color: "#288cfa" },
  { name: "sBTC", value: 10063, color: "#ff6b35" },
  { name: "DeFi", value: 5000, color: "#4caf50" },
]

const performanceData = [
  { date: "Jan 1", value: 75000 },
  { date: "Jan 8", value: 78500 },
  { date: "Jan 15", value: 82000 },
  { date: "Jan 22", value: 79500 },
  { date: "Jan 29", value: 85000 },
  { date: "Feb 5", value: 87543 },
]

const recentActivity = [
  {
    id: 1,
    type: "stake",
    description: "Staked 5,000 STX",
    amount: "+5,000 STX",
    status: "completed",
    timestamp: "2 hours ago",
    txHash: "0x1234...5678",
  },
  {
    id: 2,
    type: "bridge",
    description: "Bridged Bitcoin to sBTC",
    amount: "+0.05 sBTC",
    status: "pending",
    timestamp: "4 hours ago",
    txHash: "0x9abc...def0",
  },
  {
    id: 3,
    type: "swap",
    description: "Swapped STX for ALEX",
    amount: "-2,500 STX",
    status: "completed",
    timestamp: "1 day ago",
    txHash: "0x2468...ace0",
  },
  {
    id: 4,
    type: "claim",
    description: "Claimed stacking rewards",
    amount: "+125 STX",
    status: "completed",
    timestamp: "2 days ago",
    txHash: "0x1357...bdf9",
  },
]

export default function DashboardPage() {
  const [performancePeriod, setPerformancePeriod] = useState("7d")

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "completed":
        return <CheckCircle className="w-4 h-4 text-success" />
      case "pending":
        return <Clock className="w-4 h-4 text-primary" />
      case "failed":
        return <AlertCircle className="w-4 h-4 text-destructive" />
      default:
        return <Clock className="w-4 h-4 text-muted-foreground" />
    }
  }

  const getActivityIcon = (type: string) => {
    switch (type) {
      case "stake":
        return "🔒"
      case "bridge":
        return "🌉"
      case "swap":
        return "🔄"
      case "claim":
        return "💰"
      default:
        return "📊"
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-foreground mb-2">Portfolio Overview</h1>
        <p className="text-muted-foreground">
          Welcome to your Bitcoin DeFi command center. Track and manage all your Stacks positions in one place.
        </p>
      </div>

      {/* Portfolio Value Card */}
      <Card className="bg-gradient-to-r from-primary/5 to-primary/10 border-primary/20">
        <CardContent className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-muted-foreground mb-1">Total Portfolio Value</p>
              <h2 className="text-3xl font-bold text-foreground font-mono">{portfolioData.total_usd}</h2>
              <div className="flex items-center gap-2 mt-2">
                <TrendingUp className="w-4 h-4 text-success" />
                <span className="text-success font-medium">{portfolioData.change_24h}</span>
                <span className="text-sm text-muted-foreground">(24h)</span>
              </div>
            </div>
            <div className="text-right">
              <div className="text-sm text-muted-foreground mb-1">Performance</div>
              <div className="text-lg font-semibold text-success">+12.3%</div>
              <div className="text-xs text-muted-foreground">This month</div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Quick Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Total Staked STX</p>
                <p className="text-2xl font-bold text-foreground font-mono">{portfolioData.assets.STX.staked}</p>
                <p className="text-sm text-muted-foreground">of {portfolioData.assets.STX.balance}</p>
              </div>
              <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center">
                <span className="text-xl">🔒</span>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">sBTC Balance</p>
                <p className="text-2xl font-bold text-foreground font-mono">{portfolioData.assets.sBTC.balance}</p>
                <p className="text-sm text-muted-foreground">{portfolioData.assets.sBTC.usd_value}</p>
              </div>
              <div className="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
                <span className="text-xl">₿</span>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Active DeFi Positions</p>
                <p className="text-2xl font-bold text-foreground">{defiPositions.length}</p>
                <p className="text-sm text-muted-foreground">Across 3 protocols</p>
              </div>
              <div className="w-12 h-12 bg-success/10 rounded-lg flex items-center justify-center">
                <TrendingUp className="w-6 h-6 text-success" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Pending Transactions</p>
                <p className="text-2xl font-bold text-foreground">1</p>
                <p className="text-sm text-muted-foreground">sBTC bridge</p>
              </div>
              <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center">
                <Clock className="w-6 h-6 text-primary" />
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Asset Allocation Chart */}
        <Card>
          <CardHeader>
            <CardTitle>Asset Allocation</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-64">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={assetAllocation}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={100}
                    paddingAngle={5}
                    dataKey="value"
                  >
                    {assetAllocation.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip formatter={(value: number) => [`$${value.toLocaleString()}`, "Value"]} />
                </PieChart>
              </ResponsiveContainer>
            </div>
            <div className="grid grid-cols-2 gap-4 mt-4">
              {assetAllocation.map((asset) => (
                <div key={asset.name} className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded-full" style={{ backgroundColor: asset.color }}></div>
                  <span className="text-sm text-foreground">{asset.name}</span>
                  <span className="text-sm text-muted-foreground ml-auto">${asset.value.toLocaleString()}</span>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Performance Chart */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle>Portfolio Performance</CardTitle>
              <div className="flex gap-1">
                {["7d", "30d", "90d"].map((period) => (
                  <Button
                    key={period}
                    variant={performancePeriod === period ? "default" : "ghost"}
                    size="sm"
                    onClick={() => setPerformancePeriod(period)}
                  >
                    {period}
                  </Button>
                ))}
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <div className="h-64">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={performanceData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                  <XAxis dataKey="date" stroke="#64748b" fontSize={12} />
                  <YAxis stroke="#64748b" fontSize={12} />
                  <Tooltip
                    formatter={(value: number) => [`$${value.toLocaleString()}`, "Portfolio Value"]}
                    labelStyle={{ color: "#242c34" }}
                    contentStyle={{ backgroundColor: "#ffffff", border: "1px solid #e2e8f0" }}
                  />
                  <Line
                    type="monotone"
                    dataKey="value"
                    stroke="#288cfa"
                    strokeWidth={2}
                    dot={{ fill: "#288cfa", strokeWidth: 2, r: 4 }}
                    activeDot={{ r: 6, stroke: "#288cfa", strokeWidth: 2 }}
                  />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* DeFi Positions Overview */}
      <Card>
        <CardHeader>
          <CardTitle>DeFi Positions Overview</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {defiPositions.map((position, index) => (
              <div key={index} className="flex items-center justify-between p-4 bg-muted/50 rounded-lg">
                <div className="flex items-center gap-4">
                  <div className="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center">
                    <span className="text-sm font-semibold text-primary">
                      {position.protocol.slice(0, 2).toUpperCase()}
                    </span>
                  </div>
                  <div>
                    <div className="font-medium text-foreground">{position.protocol}</div>
                    <div className="text-sm text-muted-foreground">{position.type}</div>
                  </div>
                </div>
                <div className="text-right">
                  <div className="font-medium text-foreground">{position.value}</div>
                  <div className="text-sm text-success">{position.apy} APY</div>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Recent Activity */}
      <Card>
        <CardHeader>
          <CardTitle>Recent Activity</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {recentActivity.map((activity) => (
              <div
                key={activity.id}
                className="flex items-center gap-4 p-4 hover:bg-muted/50 rounded-lg transition-colors"
              >
                <div className="text-2xl">{getActivityIcon(activity.type)}</div>
                <div className="flex-1">
                  <div className="flex items-center gap-2">
                    <span className="font-medium text-foreground">{activity.description}</span>
                    {getStatusIcon(activity.status)}
                  </div>
                  <div className="flex items-center gap-4 mt-1">
                    <span className="text-sm text-muted-foreground">{activity.timestamp}</span>
                    <button className="text-sm text-primary hover:underline flex items-center gap-1">
                      {activity.txHash}
                      <ExternalLink className="w-3 h-3" />
                    </button>
                  </div>
                </div>
                <div className="text-right">
                  <div
                    className={`font-medium ${activity.amount.startsWith("+") ? "text-success" : "text-foreground"}`}
                  >
                    {activity.amount}
                  </div>
                  <Badge
                    variant={
                      activity.status === "completed"
                        ? "secondary"
                        : activity.status === "pending"
                          ? "default"
                          : "destructive"
                    }
                  >
                    {activity.status}
                  </Badge>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
