require "rails_helper"

RSpec.describe TasksHelper, type: :helper do
     describe "#estimate_label" do
          it "labels a missing legacy estimate as Not estimated" do
               expect(helper.estimate_label(nil)).to eq("Not estimated")
          end

          it "describes variance as over, under or on the estimate" do
               expect(helper.variance_label(BigDecimal("1.5"))).to eq("1.5 hours over estimate")
               expect(helper.variance_label(BigDecimal("-1"))).to eq("1 hour under estimate")
               expect(helper.variance_label(0)).to eq("On estimate")
          end

          it "formats saved estimates in hours, including zero" do
               expect(helper.estimate_label(BigDecimal("10"))).to eq("10 hours")
               expect(helper.estimate_label(BigDecimal("0"))).to eq("0 hours")
               expect(helper.estimate_label(BigDecimal("1"))).to eq("1 hour")
               expect(helper.estimate_label(BigDecimal("2.25"))).to eq("2.25 hours")
          end
     end
end
