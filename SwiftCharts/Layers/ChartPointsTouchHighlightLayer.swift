//
//  ChartPointsTouchHighlightLayer.swift
//  SwiftCharts
//
//  Created by Nathan Racklyeft on 2/21/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit


/// Displays a single view for a point in response to a pan gesture
public class ChartPointsTouchHighlightLayer<T: ChartPoint, U: UIView>: ChartPointsViewsLayer<T, U> {
    public typealias ChartPointLayerModelForScreenLocFilter = (screenLoc: CGPoint, chartPointModels: [ChartPointLayerModel<T>]) -> ChartPointLayerModel<T>?

    public private(set) var view: UIView?

    private let chartPointLayerModelForScreenLocFilter: ChartPointLayerModelForScreenLocFilter

    public let panGestureRecognizer: UIPanGestureRecognizer

    weak var chart: Chart?

    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], gestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(), modelFilter: ChartPointLayerModelForScreenLocFilter, viewGenerator: ChartPointViewGenerator) {
        chartPointLayerModelForScreenLocFilter = modelFilter
        panGestureRecognizer = gestureRecognizer

        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: viewGenerator)
    }

    override func display(chart chart: Chart) {
        let view = UIView(frame: chart.bounds)
        self.chart = chart

        panGestureRecognizer.addTarget(self, action: "handlePan:")

        if panGestureRecognizer.view == nil {
            view.addGestureRecognizer(panGestureRecognizer)
        }

        chart.addSubview(view)
        self.view = view
    }

    public var highlightedPoint: T? {
        get {
            return highlightedModel?.chartPoint
        }
        set {
            if let index = chartPointsModels.indexOf({ $0.chartPoint == newValue }) {
                highlightedModel = chartPointsModels[index]
            } else {
                highlightedModel = nil
            }
        }
    }

    var highlightedModel: ChartPointLayerModel<T>? {
        didSet {
            if highlightedModel?.index != oldValue?.index, let view = view, chart = chart
            {
                for subview in view.subviews {
                    subview.removeFromSuperview()
                }

                if let model = highlightedModel, pointView = viewGenerator(chartPointModel: model, layer: self, chart: chart) {
                    view.addSubview(pointView)
                }
            }

        }
    }

    @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Possible:
            // Follow your dreams!
            break
        case .Began, .Changed:
            if let view = view {
                let point = gestureRecognizer.locationInView(view)

                highlightedModel = chartPointLayerModelForScreenLocFilter(screenLoc: point, chartPointModels: chartPointsModels)
            }
        case .Cancelled, .Failed, .Ended:
            break
        }
    }
}
