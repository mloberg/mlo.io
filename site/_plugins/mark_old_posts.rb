# Mark Old Posts Liquid Tag
#
# A liquid tag for Jekyll sites to mark old posts as deprecated
#
# Usage:
#     {% mark_old_posts <time_ago_in_words|date> %}
#
# Example:
#     {% mark_old_posts 6 months ago %}
#     {% mark_old_posts 1 year ago %}
#     {% mark_old_posts 01/01/2012 %}
#
# Requires:
#     chronic gem: sudo gem install chronic --no-ri --no-rdoc
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# @author Adam Brett <adam@adambrett.co.uk>
# @license BSD-3-Clause
# @version 0.1
# @link http://gist.github.com/adambrett/
# @link http://adamcod.es/2013/02/12/mark-old-posts-liquid-tag-jekyll.html
#

require 'chronic'

module Jekyll
  class MarkOldPostTag < Liquid::Tag
    def initialize(tag_name, cut_off, tokens)
      super
      @cut_off_date = Chronic.parse(cut_off)
      @cut_off = cut_off.strip
    end

    def render(context)
      post_date = context.environments.first["page"]["date"]

      unless (post_date.is_a? Time) && (@cut_off_date.is_a? Time)
        return ""
      end

      if context.environments.first["page"]["mark_old_post"] == false
        return ""
      end

      if post_date > @cut_off_date
        return ""
      end

      html_output_for context.environments.first["page"]["date"]
    end

    def html_output_for(post_date)
      post_date = post_date.strftime("%A, %B %d, %Y")

      return <<-HTML
<div class="alert alert-warning">
  <p>
    This article was published on <strong>#{post_date}</strong>; more than
    <strong>#{@cut_off}</strong>. This means the content may be out of date or
    no longer relevant. You should <strong>verify that the technical information
    in this article is still current</strong> before relying upon it for your
    own purposes.
  </p>
</div>
      HTML
    end
  end
end

Liquid::Template.register_tag('mark_old_posts', Jekyll::MarkOldPostTag)
